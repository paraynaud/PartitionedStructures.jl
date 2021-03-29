using PartitionnedStructures.M_part_v
using PartitionnedStructures.M_elemental_pv
using PartitionnedStructures.M_internal_pv
using PartitionnedStructures.M_elemental_elt_vec

using BenchmarkTools, ProfileView, Test

using SparseArrays, LinearAlgebra

@testset "premier test" begin 
	N = 30
	nᵢ = 50
	pev = rand_epv(N,nᵢ)
	v1 = build_v!(pev)
	v2 = build_v!(pev)
	@test v1 == v2
	
	piv = rand_ipv(N,nᵢ)
end 

not_last && @testset "test k-chained et build_v!" begin 
	N = 100
	k = 4

	# elemental
	epv = ones_kchained_epv(N,k)
	build_v!(epv)
	epv_v = get_v(epv)
	@test sum(epv_v) == N*k

	# internal
	ipv = ipv_from_epv(epv)
	ipv_v = build_v(ipv)
	@test sum(ipv_v) == N*k

end 

@testset "test fonction création epv" begin 
	# elemental
	n = 10
	N = 2
	s1 = sparsevec([1:2:5;],[1:3;],n)
	s2 = sparsevec([1,3,4],[1:3;],n)

	ev1 = eev_from_sparse_vec(s1)
	ev2 = eev_from_sparse_vec(s2)

	epv = create_epv([ev1,ev2]; n=n)
	epv_sp = create_epv([s1,s2]; n=n)
	@test epv == epv_sp

	epv_v = build_v(epv)
	build_v(epv)
	@test (@allocated build_v(epv)) == 0
	
	# internal
	ipv = ipv_from_epv(epv)
	ipv_v = build_v(ipv)

	@test (@allocated build_v(ipv)) == 0

	@test epv_v == ipv_v
end


# bi = @benchmark build_v!(ipv)
# be = @benchmark build_v!(epv)
# ProfileView.@profview @benchmark build_v!(ipv)