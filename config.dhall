let Monocle =
        ../dhall-monocle/package.dhall
      ? https://raw.githubusercontent.com/change-metrics/dhall-monocle/master/package.dhall

let Prelude =
      https://prelude.dhall-lang.org/v17.0.0/package.dhall sha256:10db3c919c25e9046833df897a8ffe2701dc390fa0893d958c3430524be5a43e

let default_since = "2000-01-01"

let default_gh_secret = env:SECRET as Text ? "no-secret"

let mkSimpleGHOrg =
      λ(repository : Optional Text) →
      λ(name : Text) →
        let gh =
              Monocle.GitHub::{
              , name
              , updated_since = default_since
              , base_url = "https://github.com"
              , token = Some default_gh_secret
              }

        in  if    Prelude.Optional.null Text repository
            then  gh
            else  gh ⫽ { repository }

let mkSimpleGHIndex =
      λ(name : Text) →
        Monocle.Index::{
        , index = name
        , crawler = Monocle.Crawler::{
          , loop_delay = 300
          , github_orgs = Some [ mkSimpleGHOrg (None Text) name ]
          }
        }

let gh_orgs = [ "bitcoin", "python", "elastic", "kubernetes", "dhall-lang" ]

let ansible_index =
      let ansible_orgs =
            [ "ansible", "ansible-community", "ansible-collections" ]

      let repos =
              [ { org = "CiscoDevNet", repo = "ansible-aci" }
              , { org = "CiscoDevNet", repo = "ansible-intersight" }
              , { org = "CiscoDevNet", repo = "ansible-meraki" }
              , { org = "CiscoDevNet", repo = "ansible-mso" }
              , { org = "CiscoDevNet", repo = "anisble-ucs" }
              , { org = "F5Networks", repo = "f5-anisble" }
              , { org = "Pure-Storage-Ansible", repo = "FlashArray-Collection" }
              , { org = "Pure-Storage-Ansible", repo = "FlashBlade-Collection" }
              , { org = "ServiceNowITOM", repo = "servicenow-ansible" }
              , { org = "ansible-security"
                , repo = "ansible_collections.ibm.qradar"
                }
              , { org = "ansible-security"
                , repo = "ansible_collections.splunk.enterprise_security"
                }
              , { org = "chocolatey", repo = "chocolatey-ansible" }
              , { org = "containers", repo = "ansible-podman-collections" }
              , { org = "cyberark"
                , repo = "ansible-security-automation-collection"
                }
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
            : List { org : Text, repo : Text }

      let repoTomkSimpleGHOrg =
            λ(repo : { org : Text, repo : Text }) →
              mkSimpleGHOrg (Some repo.repo) repo.org

      let index =
            Monocle.Index::{
            , index = "ansible"
            , crawler = Monocle.Crawler::{
              , loop_delay = 300
              , github_orgs = Some
                  (   Prelude.List.map
                        Text
                        Monocle.GitHub.Type
                        (mkSimpleGHOrg (None Text))
                        ansible_orgs
                    # Prelude.List.map
                        { org : Text, repo : Text }
                        Monocle.GitHub.Type
                        repoTomkSimpleGHOrg
                        repos
                  )
              , gerrit_repositories = Some
                [ Monocle.Gerrit::{
                  , name = "^openstack/ansible-collections-openstack"
                  , updated_since = default_since
                  , base_url = "https://review.opendev.org"
                  }
                ]
              }
            }

      in  index

let createSimpleGHIndexes =
      Prelude.List.map Text Monocle.Index.Type mkSimpleGHIndex gh_orgs

let config = { tenants = createSimpleGHIndexes # [ ansible_index ] }

in  config
