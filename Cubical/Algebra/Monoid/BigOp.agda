{-# OPTIONS --safe #-}
module Cubical.Algebra.Monoid.BigOp where

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.Equiv
open import Cubical.Foundations.Equiv.HalfAdjoint
open import Cubical.Foundations.Function
open import Cubical.Foundations.HLevels
open import Cubical.Foundations.Isomorphism
open import Cubical.Foundations.Univalence
open import Cubical.Foundations.Transport
open import Cubical.Foundations.SIP

open import Cubical.Data.Sigma
open import Cubical.Data.Nat hiding (_·_)
-- open import Cubical.Data.Vec -- upstream def of FinVec?
open import Cubical.Data.FinData

open import Cubical.Algebra.Semigroup
open import Cubical.Algebra.Monoid.Base

open Iso

private
  variable
    ℓ : Level
    A : Type ℓ

-- nothing is proved about this except equiv with Vec
FinVec : (A : Type ℓ) (n : ℕ) → Type ℓ
FinVec A n = Fin n → A

replicateFinVec : (n : ℕ) → A → FinVec A n
replicateFinVec _ a _ = a

module _ (M' : Monoid ℓ) where
 private M = ⟨ M' ⟩
 open MonoidStr (snd M')

 bigOp : {n : ℕ} → FinVec M n → M
 bigOp = foldrFin _·_ ε

 bigOpExt : ∀ {n} {V W : FinVec M n} → ((i : Fin n) → V i ≡ W i) → bigOp V ≡ bigOp W
 bigOpExt {n = zero} _ = refl
 bigOpExt {n = suc n} h i = h zero i · bigOpExt (h ∘ suc) i

 bigOpε : ∀ n → bigOp (replicateFinVec n ε) ≡ ε
 bigOpε zero = refl
 bigOpε (suc n) = cong (ε ·_) (bigOpε n) ∙ rid _


 -- requires a commutative monoid:
 bigOpSplit : (∀ x y → x · y ≡ y · x)
            → {n : ℕ} → (V W : FinVec M n) → bigOp (λ i → V i · W i) ≡ bigOp V · bigOp W
 bigOpSplit _ {n = zero} _ _ = sym (rid _)
 bigOpSplit comm {n = suc n} V W =
    V zero · W zero · bigOp (λ i → V (suc i) · W (suc i))
  ≡⟨ (λ i → V zero · W zero · bigOpSplit comm (V ∘ suc) (W ∘ suc) i) ⟩
    V zero · W zero · (bigOp (V ∘ suc) · bigOp (W ∘ suc))
  ≡⟨ sym (assoc _ _ _) ⟩
    V zero · (W zero · (bigOp (V ∘ suc) · bigOp (W ∘ suc)))
  ≡⟨ cong (V zero ·_) (assoc _ _ _) ⟩
    V zero · ((W zero · bigOp (V ∘ suc)) · bigOp (W ∘ suc))
  ≡⟨ cong (λ x → V zero · (x · bigOp (W ∘ suc))) (comm _ _) ⟩
    V zero · ((bigOp (V ∘ suc) · W zero) · bigOp (W ∘ suc))
  ≡⟨ cong (V zero ·_) (sym (assoc _ _ _)) ⟩
    V zero · (bigOp (V ∘ suc) · (W zero · bigOp (W ∘ suc)))
  ≡⟨ assoc _ _ _ ⟩
    V zero · bigOp (V ∘ suc) · (W zero · bigOp (W ∘ suc)) ∎

