module PartitionedLOQuasiNewton
	using LinearAlgebra

  using ..M_abstract_part_struct, ..M_elt_vec, ..M_part_mat, ..M_elt_mat
  using ..Utils
  using ..ModElemental_ev, ..ModElemental_pv
  using ..ModElemental_elom_bfgs, ..ModElemental_plom
	using ..ModElemental_plom_bfgs, ..ModElemental_plom_sr1
  
  export PLBFGS_update, PLBFGS_update!
	export PLSR1_update, PLSR1_update!
  export Part_update, Part_update!

  """ 
      PLBFGS_update(eplom_B, s, epv_y)
  Define the partitioned LBFGS update of the partioned matrix eplom_B, given the step s and the element gradient difference epv_y
  """
  PLBFGS_update(eplom_B :: Elemental_plom_bfgs{T}, epv_y :: Elemental_pv{T}, s :: Vector{T}) where T = begin epm_copy = copy(eplom_B); PLBFGS_update!(epm_copy,epv_y,s); return epm_copy end 
  PLBFGS_update!(eplom_B :: Elemental_plom_bfgs{T}, epv_y :: Elemental_pv{T}, s :: Vector{T}) where T = begin epv_s = epv_from_v(s, epv_y); PLBFGS_update!(eplom_B, epv_y, epv_s) end
  function PLBFGS_update!(eplom_B :: Elemental_plom_bfgs{T}, epv_y :: Elemental_pv{T}, epv_s :: Elemental_pv{T}) where T 
    full_check_epv_epm(eplom_B,epv_y) || @error("differents partitioned structures between eplom_B and epv_y")
    full_check_epv_epm(eplom_B,epv_s) || @error("differents partitioned structures between eplom_B and epv_s")
    N = get_N(eplom_B)
		acc_up = 0
		acc_reset = 0
    for i in 1:N      
			eelomi = get_eelom_set(eplom_B, i)
      si = get_vec(get_eev(epv_s,i))
      yi = get_vec(get_eev(epv_y,i))			
			if (dot(si,yi) > eps(T))
				acc_up += 1
				Bi = get_Bie(eelomi)
      	push!(Bi, si, yi)			
			else 
				acc_reset += 1
				reset_eelom_bfgs!(eelomi)
			end 
    end 
		println(" PLBFGS, update $(acc_up)/$(N) elements et reset $(acc_reset)/$(N) ")
  end

	""" 
      PLSR1_update(eplom_B, s, epv_y)
  Define the partitioned LSR1 update of the partioned matrix eplom_B, given the step s and the element gradient difference epv_y
  """
  PLSR1_update(eplom_B :: Elemental_plom_sr1{T}, epv_y :: Elemental_pv{T}, s :: Vector{T}) where T = begin epm_copy = copy(eplom_B); PLSR1_update!(epm_copy,epv_y,s); return epm_copy end 
  PLSR1_update!(eplom_B :: Elemental_plom_sr1{T}, epv_y :: Elemental_pv{T}, s :: Vector{T}) where T = begin epv_s = epv_from_v(s, epv_y); PLSR1_update!(eplom_B, epv_y, epv_s) end
  function PLSR1_update!(eplom_B :: Elemental_plom_sr1{T}, epv_y :: Elemental_pv{T}, epv_s :: Elemental_pv{T}; ω = 1e-6) where T 
    full_check_epv_epm(eplom_B,epv_y) || @error("differents partitioned structures between eplom_B and epv_y")
    full_check_epv_epm(eplom_B,epv_s) || @error("differents partitioned structures between eplom_B and epv_s")
    N = get_N(eplom_B)
		acc_up = 0
		acc_reset = 0
    for i in 1:N      
			eelomi = get_eelom_set(eplom_B, i)
      si = get_vec(get_eev(epv_s,i))
      yi = get_vec(get_eev(epv_y,i))
			Bi = get_Bie(eelomi)
			ri = yi .- Bi*si
    	if abs(dot(si,ri)) > ω * norm(si,2) * norm(ri,2)
				acc_up += 1
      	push!(Bi, si, yi)			
			else 
				acc_reset += 1
				reset_eelom_sr1!(eelomi)
			end 
    end 
		println(" PLSR1, update $(acc_up)/$(N) elements et reset $(acc_reset)/$(N) ")
  end

  """
      Part_update(eplom_B, epv_y, s)
  Perform the partitionned update of eplom_B.
  eplom_B is build from LBFGS or LSR1 elemental element matrices.
  The update performed on eachh element matrix correspond to the linear operator associated.
  """
  Part_update(eplom_B :: Y, epv_y :: Elemental_pv{T}, s :: Vector{T}) where Y <: Part_LO_mat{T} where T = begin epm_copy = copy(eplom_B); Part_update!(epm_copy,epv_y,s); return epm_copy end 
  Part_update!(eplom_B :: Y, epv_y :: Elemental_pv{T}, s :: Vector{T}) where Y <: Part_LO_mat{T} where T = begin epv_s = epv_from_v(s, epv_y); Part_update!(eplom_B, epv_y, epv_s) end
  function Part_update!(eplom_B :: Y, epv_y :: Elemental_pv{T}, epv_s :: Elemental_pv{T}) where Y <: Part_LO_mat{T} where T 
    full_check_epv_epm(eplom_B,epv_y) || @error("differents partitioned structures between eplom_B and epv_y")
    full_check_epv_epm(eplom_B,epv_s) || @error("differents partitioned structures between eplom_B and epv_s")
    N = get_N(eplom_B)
    for i in 1:N
      Bi = get_Bie(get_eelom_set(eplom_B, i))
      si = get_vec(get_eev(epv_s,i))
      yi = get_vec(get_eev(epv_y,i))
      push!(Bi, si, yi)
    end 
  end

end 