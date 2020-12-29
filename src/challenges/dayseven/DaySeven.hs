{-# LANGUAGE FlexibleInstances #-}

module DaySeven where

import Challenge

import Text.Parsec as Parsec
import Data.List (partition, isInfixOf)

data Section
  = Supernet String
  | Hypernet String deriving (Show)

newtype IPv7 = IPv7 [Section] deriving (Show)

supernet :: Parsec.Parsec String () Section
supernet = Supernet <$> Parsec.between (Parsec.char '[') (Parsec.char ']') (Parsec.many1 Parsec.letter)

hypernet :: Parsec.Parsec String () Section
hypernet = Hypernet <$> Parsec.many1 Parsec.letter

section :: Parsec.Parsec String () Section
section = supernet <|> hypernet

parseipv7 :: Parsec.Parsec String () IPv7
parseipv7 = IPv7 <$> Parsec.many1 section

parseipv7s :: Parsec.Parsec String () [IPv7]
parseipv7s = Parsec.sepBy1 parseipv7 Parsec.endOfLine

parse' :: String -> [IPv7]
parse' input =
  case Parsec.parse parseipv7s "" input of
    Left err -> error $ show err
    Right ips -> ips
    
    
    
data Address = Address  { hypernets :: [String]
                        , supernets :: [String]
                        }
                    
convert :: IPv7 -> Address
convert = undefined

hasABBA :: String -> Bool
hasABBA s
  | length s < 4 = False
  | otherwise =
    let piece = take 4 s in
    take 1 piece /= take 1 (drop 1 piece) && reverse piece == piece || hasABBA (tail s)

abbaCompliant :: Section -> Bool
abbaCompliant (Hypernet section) = hasABBA section
abbaCompliant (Supernet section) = not (hasABBA section)

supportsTLS :: IPv7 -> Bool
supportsTLS (IPv7 sections) =
  let (normals, brackets) = partition f sections
  in any abbaCompliant normals && all abbaCompliant brackets
  where
    f :: Section -> Bool
    f (Supernet _)  = False
    f (Hypernet _)  = True
    
abababCompliant :: String -> [String] -> Bool
abababCompliant s = any (isInfixOf s)

supportsSSL :: IPv7 -> Bool
supportsSSL (IPv7 sections) = 
  let (normals, brackets) = partition f sections
  in any abbaCompliant normals && all abbaCompliant brackets
  where
    f :: Section -> Bool
    f (Supernet _)  = False
    f (Hypernet _)  = True

instance Challenge [IPv7] where
  parse = parse'
  partOne = show . length . filter supportsTLS
  partTwo = show . length . filter supportsSSL

