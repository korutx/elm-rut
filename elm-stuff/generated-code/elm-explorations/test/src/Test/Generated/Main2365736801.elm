module Test.Generated.Main2365736801 exposing (main)

import RutTest

import Test.Reporter.Reporter exposing (Report(..))
import Console.Text exposing (UseColor(..))
import Test.Runner.Node
import Test

main : Test.Runner.Node.TestProgram
main =
    [     Test.describe "RutTest" [RutTest.suite] ]
        |> Test.concat
        |> Test.Runner.Node.run { runs = Nothing, report = (ConsoleReport UseColor), seed = 11756543521063, processes = 2, paths = ["/home/ec2-user/environment/elm-rut/tests/RutTest.elm"]}