module GribImport

using GRIB

filepath = "C:/Users/DELL/Desktop/ShipOptimizationApp/ShipOptimizationApp/assets/ECMWF_WRCTPaG_100k_5d_12h_60N_51S_22E_13W_20240526_2005.grb"

grib_file = GRIB.GribFile(filepath)

cnt = 0
message = Message(grib_file)
println(values(message))
for v in values(message)
    global cnt
    println(v)
    cnt += 1
    # println(key(v))
end

println(string("COUNTER: ", cnt))
# println("DUPA DUPA DUPA")

cnt = 0
for k in keys(message)
    global cnt
    println(k)
    cnt += 1
end

println(string("COUNTER: ", cnt))

println(typeof(values(message)))

end