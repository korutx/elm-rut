module Rut exposing ( format, computeDv, isValidRut, Formatter(..) )

{-| Formatear, calcular el dígito verificador y probar la validez de un rut

# Types
@docs Formatter

# Api
@docs format, computeDv, isValidRut
-}

import Regex exposing ( fromString )

{-| Types for the formatter
    format Cleared "11.111.111-1" == "111111111"
    format Simple "11.111.111-1" == "11111111-1"
    format ThousandsSeparated "11111111-1" == "11.111.111-1" 
-}
type Formatter = 
    ThousandsSeparated
    | Simple
    | Cleared

type alias Rut = 
    { rut : Maybe String
    , dv : Maybe String
    }

thousandsFormatter : Char -> String -> String
thousandsFormatter char text =
    if String.length text > 0 && modBy 3 ( String.length ( clearFormat text ) ) == 0 then 
       ( String.fromChar char )  ++ "." ++ text 
    else 
        ( String.fromChar char ) ++ text

thousandsFormat : String -> String
thousandsFormat = String.foldr thousandsFormatter ""

justStr : Maybe String -> String
justStr maybeStr =
    case maybeStr of 
        Nothing -> ""
        Just str -> str

{-| format rut to a one of Cleared, Simple or ThousandsSeparated
    format Cleared "11.111.111-1" == "111111111"
    format Simple "11.111.111-1" == "11111111-1"
    format ThousandsSeparated "11111111-1" == "11.111.111-1" 
-} 
format : Formatter -> String -> Maybe String
format formatter value =
    let
        rutdv = splitRutAndDv value
    in
    if rutdv.rut == Nothing then
        Just value
    else if rutdv.rut /= Nothing && rutdv.dv == Nothing then
        rutdv.rut
    else case formatter of
        ThousandsSeparated -> Just ( ( thousandsFormat ( justStr rutdv.rut ) ) ++ "-" ++ ( justStr rutdv.dv ) ) 
        Simple -> Just ( ( justStr rutdv.rut ) ++ "-" ++ ( justStr rutdv.dv ) )
        Cleared -> Just ( ( justStr rutdv.rut ) ++ ( justStr rutdv.dv ) )
    
splitRutAndDv : String -> Rut
splitRutAndDv str =
    let
        clearedStr = clearFormat str
    in
    case String.length clearedStr of
        0 -> { rut = Nothing, dv = Nothing }
        1 -> { rut = Just clearedStr, dv = Nothing }
        _ -> { rut = Just ( String.slice 0 -1 clearedStr ), dv = Just ( String.right 1 clearedStr ) }
        
{-| Clear the format of a rut
    clearFormat "11.111.111-1" == "111111111"
-}   
clearFormat : String -> String
clearFormat str = replace "[\\.\\-]" ( \_ -> "" ) str
    
replace : String -> ( Regex.Match -> String ) -> String -> String
replace regexStr replacer str =
  case fromString regexStr of
    Nothing -> str
    Just regex -> Regex.replace regex replacer str

{-| Compute the virifier digit for a rut, it must be a cleared rut without verifier digit
    computeDv "11111111"
-}
computeDv : String -> String   
computeDv rut = 
    let
        ( s, m ) = List.foldr 
            ( \d ( suma, mul ) -> 
                let
                    mul1 = modBy 8 ( mul + 1 )
                    mul2 = if mul1 > 0 then mul1 else 2
                    num = ( Char.toCode d ) - 48
                in
                ( suma +  num * mul, mul2 ) 
            ) 
            ( 0, 2 ) 
            ( String.toList rut )
    in
    case modBy 11 s of
        1 -> "k"
        0 -> "0"
        _ -> String.fromInt ( 11 - ( modBy 11 s ) )


{-| Test if a rut string is valid
    isValidRut 2 "11.111.111-1"
-}       
isValidRut : Int -> String -> Bool
isValidRut minimumLength rut =
    let
        crut = clearFormat(rut)
    in
    if String.length crut < minimumLength then
        False
    else
        let
            rutdv = splitRutAndDv rut
        in
        computeDv(justStr rutdv.rut) == justStr rutdv.dv