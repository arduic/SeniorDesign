package config is
constant INPUT_FILE: string := "C:\Users\lc599.DREXEL.000\SeniorDesign\FFT\scripts\data_in.txt";
constant OUTPUT_FILE: string := "C:\Users\lc599.DREXEL.000\SeniorDesign\FFT\scripts\data_out.txt";
constant FFTLEN: integer := 256;
constant WINDOWS: integer := 4;
constant KR: integer := 178;
constant KD: integer := 533;
constant INPUT_WIDTH: integer := 8;
type FREQ_SPEC_T is array(0 to FFTLEN-1) of integer;
type FREQ_BUFF_T is array(0 to WINDOWS-1) of integer;
constant FREQ_SPEC: FREQ_SPEC_T := (0,53426,106852,160278,213704,267130,320556,373982,427408,480834,534260,587686,641112,694538,747964,801390,854816,908241,961667,1015093,1068519,1121945,1175371,1228797,1282223,1335649,1389075,1442501,1495927,1549353,1602779,1656205,1709631,1763056,1816482,1869908,1923334,1976760,2030186,2083612,2137038,2190464,2243890,2297316,2350742,2404168,2457594,2511020,2564446,2617871,2671297,2724723,2778149,2831575,2885001,2938427,2991853,3045279,3098705,3152131,3205557,3258983,3312409,3365835,3419261,3472686,3526112,3579538,3632964,3686390,3739816,3793242,3846668,3900094,3953520,4006946,4060372,4113798,4167224,4220650,4274076,4327502,4380927,4434353,4487779,4541205,4594631,4648057,4701483,4754909,4808335,4861761,4915187,4968613,5022039,5075465,5128891,5182317,5235742,5289168,5342594,5396020,5449446,5502872,5556298,5609724,5663150,5716576,5770002,5823428,5876854,5930280,5983706,6037132,6090557,6143983,6197409,6250835,6304261,6357687,6411113,6464539,6517965,6571391,6624817,6678243,6731669,6785095,6838521,6891947,6945372,6998798,7052224,7105650,7159076,7212502,7265928,7319354,7372780,7426206,7479632,7533058,7586484,7639910,7693336,7746762,7800187,7853613,7907039,7960465,8013891,8067317,8120743,8174169,8227595,8281021,8334447,8387873,8441299,8494725,8548151,8601577,8655003,8708428,8761854,8815280,8868706,8922132,8975558,9028984,9082410,9135836,9189262,9242688,9296114,9349540,9402966,9456392,9509818,9563243,9616669,9670095,9723521,9776947,9830373,9883799,9937225,9990651,10044077,10097503,10150929,10204355,10257781,10311207,10364633,10418058,10471484,10524910,10578336,10631762,10685188,10738614,10792040,10845466,10898892,10952318,11005744,11059170,11112596,11166022,11219448,11272873,11326299,11379725,11433151,11486577,11540003,11593429,11646855,11700281,11753707,11807133,11860559,11913985,11967411,12020837,12074263,12127688,12181114,12234540,12287966,12341392,12394818,12448244,12501670,12555096,12608522,12661948,12715374,12768800,12822226,12875652,12929078,12982504,13035929,13089355,13142781,13196207,13249633,13303059,13356485,13409911,13463337,13516763,13570189,13623615);
end config;