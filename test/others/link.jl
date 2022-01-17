using PartitionedStructures
using PartitionedStructures.Link, PartitionedStructures.M_part_v

epm1,epv1 = create_epv_epm(;n=9,nie=5,overlapping=1,mul_m=5., mul_v=100.)
epm2,epv2 = create_epv_epm(;n=9,nie=3,overlapping=0,mul_m=5., mul_v=100.)


@test check_epv_epm(epm1,epv1)	
@test full_check_epv_epm(epm1,epv1)	
full_check_epv_epm(epm1,epv1)	
@test check_epv_epm(epm2,epv2)	
@test full_check_epv_epm(epm2,epv2)	

@test check_epv_epm(epm2,epv1)
@test full_check_epv_epm(epm2,epv1 )== false

epm3,epv3 = create_epv_epm(;n=16,nie=6,overlapping=1,mul_m=5., mul_v=100.)

@test check_epv_epm(epm3,epv1) == false
@test full_check_epv_epm(epm3,epv1) == false