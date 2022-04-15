--| The configuration of https://demo.changemetrics.io/
let default_since = "2000-01-01"

let --| The main github organizations indexes
    gh_orgs =
      [ "bitcoin", "python", "elastic", "dhall-lang", "leanprover-community" ]

let kubernetes = [ "kubernetes", "openshift" ]

let --| The ansible index configuration: crawl the orgs and extra repository from other orgs
    ansible =
      { orgs = [ "ansible", "ansible-community", "ansible-collections" ]
      , repos =
        [ { org = "CiscoDevNet", repo = "ansible-aci" }
        , { org = "CiscoDevNet", repo = "ansible-intersight" }
        , { org = "CiscoDevNet", repo = "ansible-meraki" }
        , { org = "CiscoDevNet", repo = "ansible-mso" }
        , { org = "CiscoDevNet", repo = "ansible-ucs" }
        , { org = "F5Networks", repo = "f5-ansible" }
        , { org = "Pure-Storage-Ansible", repo = "FlashArray-Collection" }
        , { org = "Pure-Storage-Ansible", repo = "FlashBlade-Collection" }
        , { org = "ServiceNowITOM", repo = "servicenow-ansible" }
        , { org = "ansible-security", repo = "ansible_collections.ibm.qradar" }
        , { org = "ansible-security"
          , repo = "ansible_collections.splunk.enterprise_security"
          }
        , { org = "chocolatey", repo = "chocolatey-ansible" }
        , { org = "containers", repo = "ansible-podman-collections" }
        , { org = "cyberark", repo = "ansible-security-automation-collection" }
        , { org = "fortinet-ansible-dev"
          , repo = "ansible-galaxy-fortimanager-collection"
          }
        , { org = "fortinet-ansible-dev"
          , repo = "ansible-galaxy-fortios-collection"
          }
        , { org = "netbox-community", repo = "ansible_modules" }
        , { org = "ngine-io", repo = "ansible-collection-cloudstack" }
        , { org = "ngine-io", repo = "ansible-collection-vultr" }
        , { org = "theforeman", repo = "foreman-ansible-modules" }
        , { org = "wtinetworkgear", repo = "wti-collection" }
        ]
      }

let --| Belows are function to create the Monocle configuration
    Monocle =
      https://raw.githubusercontent.com/change-metrics/dhall-monocle/aa2d01c388d699d71ac73199b34b8b40e78c46aa/package.dhall
        sha256:7038cf32c731e7a94d3f1dd48cfe750b8a8f9ed8e47e42c48ee6eb9efb5639b1

let Prelude =
      https://prelude.dhall-lang.org/v17.0.0/package.dhall
        sha256:10db3c919c25e9046833df897a8ffe2701dc390fa0893d958c3430524be5a43e

let --| Create a github organization configuration
    mkGHRepo =
      λ(info : { org : Text, repo : Text }) →
        Monocle.Github::{
        , github_organization = info.org
        , github_repositories = Some [ info.repo ]
        }

let mkGHOrg =
      λ(github_organization : Text) → Monocle.Github::{ github_organization }

let mkGHCrawler =
      λ(provider : Monocle.Github.Type) →
        Monocle.Crawler::{
        , name = "gh-${provider.github_organization}"
        , update_since = default_since
        , provider = Monocle.Provider.Github provider
        }

let --| The ansible index configuration
    ansible_index =
      let ghProviders =
              Prelude.List.map Text Monocle.Github.Type mkGHOrg ansible.orgs
            # Prelude.List.map
                { org : Text, repo : Text }
                Monocle.Github.Type
                mkGHRepo
                ansible.repos

      in  Monocle.Workspace::{
          , name = "ansible"
          , crawlers =
                Prelude.List.map
                  Monocle.Github.Type
                  Monocle.Crawler.Type
                  mkGHCrawler
                  ghProviders
              # [ Monocle.Crawler::{
                  , name = "opendev-gerrit"
                  , update_since = default_since
                  , provider =
                      Monocle.Provider.Gerrit
                        Monocle.Gerrit::{
                        , gerrit_url = "https://review.opendev.org"
                        , gerrit_repositories = Some
                          [ "^openstack/ansible-collections-openstack" ]
                        }
                  }
                ]
          }

let -- | The kubernetes index configuration
    kubernetes_index =
      Monocle.Workspace::{
      , name = "kubernetes"
      , crawlers =
          Prelude.List.map
            Text
            Monocle.Crawler.Type
            (λ(name : Text) → mkGHCrawler (mkGHOrg name))
            kubernetes
      }

let --| Create a github crawler configuration for monocle
    mkSimpleGHIndex =
      λ(name : Text) →
        Monocle.Workspace::{ name, crawlers = [ mkGHCrawler (mkGHOrg name) ] }

let createSimpleGHIndexes =
      Prelude.List.map Text Monocle.Workspace.Type mkSimpleGHIndex

in  Monocle.Config::{
    , workspaces =
        createSimpleGHIndexes gh_orgs # [ ansible_index, kubernetes_index ]
    }
