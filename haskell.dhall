let default_since = "2000-01-01"

let --| Belows are function to create the Monocle configuration
    Monocle =
      https://raw.githubusercontent.com/change-metrics/monocle/db5c16b1c78e0f209ba84c9471b774e32521f5fb/schemas/monocle/config/package.dhall
        sha256:bec5b4fe2f3a191137ae4e2f3110e98131b1eae3c092193ddaf817b983932488

let Prelude =
      https://prelude.dhall-lang.org/v17.0.0/package.dhall
        sha256:10db3c919c25e9046833df897a8ffe2701dc390fa0893d958c3430524be5a43e

let mkGHOrgCrawler =
      \(name : Text) ->
        Monocle.Crawler::{
        , name = "gh-${name}"
        , update_since = default_since
        , provider =
            Monocle.Provider.Github
              Monocle.Github::{ github_organization = name }
        }

in  Monocle.Workspace::{
    , name = "haskell"
    , projects = Some
      [ Monocle.Project::{
        , name = "core-libraries"
        , repository_regex = Some
            ( Prelude.Text.concatSep
                "|"
                [ "haskell/stm"
                , "haskell/text"
                , "haskell/bytestrings"
                , "haskell/containers"
                , "haskell/network"
                , "haskell/cabal"
                , "haskell/primitive"
                , "haskell/process"
                , "haskell/time"
                , "haskell/win32"
                , "haskell/alex"
                , "haskell/happy"
                , "haskell/filepath"
                , "haskell/directory"
                ]
            )
        }
      ]
    , crawlers =
      [ mkGHOrgCrawler "haskell"
      , Monocle.Crawler::{
        , name = "ghkmett"
        , update_since = default_since
        , provider =
            Monocle.Provider.Github
              Monocle.Github::{
              , github_organization = "ekmett"
              , github_repositories = Some
                [ "lens"
                , "exceptions"
                , "profunctors"
                , "comonad"
                , "pointed"
                , "adjunctions"
                , "trifecta"
                , "ad"
                , "free"
                , "semigroupoids"
                , "gl"
                ]
              }
        }
      ]
    }
