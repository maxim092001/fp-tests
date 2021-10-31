{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE StandaloneDeriving    #-}

module Test.T1List(hspecList, propList) where
import HW2.T1 (List (..), mapList)
import Test.Hspec
import Test.Tasty
import Test.Tasty.Hspec
import Hedgehog
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Internal.Range as Range
import Test.Common
import Test.Tasty.Hedgehog

deriving instance _ => Show (List a)
deriving instance _ => Eq (List a)

listFromStdList :: [a] -> List a
listFromStdList = foldr (:.) Nil

hspecList :: IO TestTree
hspecList = testSpec "List tests:" $ do
    describe "Nil tests:" $ do
        it "Nil test" $ mapList (+ 1) Nil `shouldBe` Nil
        it "Nil(f . g) test" $ (mapList (+ 1) . mapList (* 10)) Nil `shouldBe` Nil
    describe "List tests:" $ do
        it "List test1" $ mapList (+ 1) (listFromStdList [1, 2, 3]) `shouldBe` listFromStdList [2, 3, 4]
        it "List test2" $ mapList (+ 1) (listFromStdList [3, 1, 2]) `shouldBe` listFromStdList [4, 2, 3]
        it "List(f . g) test" $ (mapList (+ 1) . mapList (* 10)) (listFromStdList [1, 2, 3]) `shouldBe` listFromStdList [11, 21, 31]

genList :: Gen (List Int)
genList = listFromStdList <$> genList'
  where
    genList' :: Gen [Int]
    genList' = Gen.list (Range.linear 1 100) genInt

propList :: TestTree
propList = testGroup "List properties" [
    testProperty "List id property" $ idProp genList mapList
  , testProperty "List composition property" $ compProp genList mapList
  ]