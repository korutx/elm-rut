module RutTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)

import Rut exposing ( format, computeDv, isValidRut, Formatter(..) )

suite : Test
suite =
    describe "The Rut module"
        [ test "Cleared format" <|
            \_ ->
                let
                    rutList = [ "111111111", "11.111.111-1", "11111111-1", "", "1", "K", "1-1" ]
                    cleared = [ "111111111", "111111111", "111111111", "", "1", "K", "11" ]
                    justCleared = List.map ( \c -> Just c ) cleared
                in
                Expect.equal justCleared ( List.map ( \rut -> format Cleared rut ) rutList )

        , test "Simple format" <|
            \_ ->
                let
                    rutList = [ "111111111", "11.111.111-1", "11111111-1", "", "1", "K", "1-1" ]
                    cleared = [ "11111111-1", "11111111-1", "11111111-1", "", "1", "K", "1-1" ]
                    justCleared = List.map ( \c -> Just c ) cleared
                in
                Expect.equal justCleared ( List.map ( \rut -> format Simple rut ) rutList )
                
        , test "Thousands Format" <|
            \_ ->
                let
                    rutList = [ "111111111", "11.111.111-1", "11111111-1", "", "1", "K", "1-1" ]
                    cleared = [ "11.111.111-1", "11.111.111-1", "11.111.111-1", "", "1", "K", "1-1" ]
                    justCleared = List.map ( \c -> Just c ) cleared
                in
                Expect.equal justCleared ( List.map ( \rut -> format ThousandsSeparated rut ) rutList )

        , test "Compute Dv" <|
            \_ ->
                let
                    rutList = [ "24952044", "11111111", "44444444", "33916942", "1773599", "7588158", "12432815", 
                                "15985120", "17566826", "19992589", "30027608", "32869435", "33344065",
                                "39191587", "39872491"]
                    cleared = [ "6", "1", "4", "k", "3", "4", "2", "6", "8", "k", "3", "2", "2", "3", "7" ]
                in
                Expect.equal cleared ( List.map ( \rut -> computeDv rut ) rutList )
                
        , test "isValidRut" <|
            \_ ->
                let
                    rutList = [ "24952044-6", "11111111-1", "44.444.444-4", "33.916.942-k", "1.773.599-0", "7588158-4", 
                                "12432815-2", "15985120-6", "17566826-8", "19992589-k", "30027608-3", "32869435-2", 
                                "33344065-2", "39191587-5", "39872491-7", "1-1" ]
                    cleared = [ 
                        True, True, True, True, False, True, True, True, True, True, True, True, True, False, True, 
                        False ]
                in
                Expect.equal cleared ( List.map ( \rut -> isValidRut 6 rut ) rutList )
        ]


