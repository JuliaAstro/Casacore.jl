@testset "Measures" begin
    using Casacore.Measures

    @testset "Direction conversion J2000 to AZEL (and back again)" begin
        direction = Measures.Direction(Measures.Directions.J2000, (π)u"rad", π/2u"rad")
        show(devnull, direction)

        # Getters/setters
        @test (direction.long -= π/4u"rad") ≈ 3π/4u"rad"
        @test direction.long ≈ 3π/4u"rad"
        @test (direction.lat -= π/2u"rad") ≈ 0u"rad"
        @test direction.lat ≈ 0u"rad"

        # Create reference frame measures
        pos = Measures.Position(Measures.Positions.ITRF, 1000u"m", 0u"m", 0u"m")
        t = Measures.Epoch(Measures.Epochs.UTC, 1234567u"d")

        show(devnull, t)
        show(devnull, pos)

        # Getters/setters
        @test (pos.x += 1u"km") == 2000u"m"
        @test pos.x == 2u"km"
        @test (pos.y += 3u"m") == 3u"m"
        @test pos.y == 3u"m"
        @test (pos.z += 5u"m") == 5u"m"
        @test pos.z == 5u"m"

        @test (t.time += 1u"d") == 1234568u"d"
        @test t.time == 1234568u"d"

        directionAZEL = mconvert(Measures.Directions.AZEL, direction, t, pos)
        @test directionAZEL.type == Measures.Directions.AZEL
        @test !isapprox(directionAZEL.lat , 0u"rad", atol=1e-4)  # Check that the conversion does something
        @test !isapprox(directionAZEL.long, 3π/4u"rad", atol=1e-4)

        @test isapprox(direction, mconvert(Measures.Directions.J2000, directionAZEL, t, pos), atol=1e-6)

        direction.type = Measures.Directions.B1950
        @test direction.type == Measures.Directions.B1950
        @test LibCasacore.getType(LibCasacore.getRef(direction.m)) == Int(Measures.Directions.B1950)
    end

    @testset "Frequency conversion REST to LSRD" begin
        freq = Measures.Frequency(Measures.Frequencies.REST, 1_420_405_752u"Hz")
        show(devnull, freq)

        @test (freq.freq +=1u"Hz") == 1_420_405_753u"Hz"
        @test freq.freq == 1_420_405_753u"Hz"

        direction = Measures.Direction(Measures.Directions.J2000, 0u"rad", π/2u"rad")
        velocity = Measures.RadialVelocity(Measures.RadialVelocities.LSRD, 20_000u"km/s", direction)
        show(devnull, velocity)

        @test (velocity.velocity += 1u"m/s") == 20_000_001u"m/s"
        @test velocity.velocity == 20_000_001u"m/s"

        freqLSRD = mconvert(Measures.Frequencies.LSRD, freq, velocity, direction)
        @test freqLSRD.freq != 1_420_405_753u"Hz"  # Check that the conversion does something

        @test freq ≈ mconvert(Measures.Frequencies.REST, freqLSRD, velocity, direction)
    end

    @testset "EarthMagnetic conversion ITRF to AZEL" begin
        # Load position by observatory name
        @test :MWA32T ∈ Measures.Positions.observatories()
        pos = Measures.Position(:MWA32T)
        @test pos.type == Measures.Positions.WGS84
        time = Measures.Epoch(Measures.Epochs.DEFAULT, 59857u"d")

        bfield = Measures.EarthMagnetic(Measures.EarthMagnetics.DEFAULT, -1u"T", -1u"T", -1u"T")

        @test (bfield.x += 1u"T") == 0u"T"
        @test bfield.x == 0u"T"
        @test (bfield.y += 2u"T") == 1u"T"
        @test bfield.y == 1u"T"
        @test (bfield.z += 5u"T") == 4u"T"
        @test bfield.z == 4u"T"

        bfield = mconvert(Measures.EarthMagnetics.AZEL, bfield, pos, time)
        @test 10_000u"nT" < hypot(bfield.x, bfield.y, bfield.z) < 100_000u"nT"  # A reasonable range
    end

    @testset "Baseline conversion from ITRF to J2000 to UVW" begin
        # Use alternative (r, long, lat) constructor for Position
        refpos = Measures.Position(Measures.Positions.ITRF, 6378.1u"km", 37u"°", -23u"°")
        @test radius(refpos) ≈ 6378.1u"km"
        @test long(refpos) ≈ 37u"°"
        @test lat(refpos) ≈ -23u"°"

        time = Measures.Epoch(Measures.Epochs.DEFAULT, 59857u"d")
        refdirection = Measures.Direction(Measures.Directions.J2000, 27u"°", 25u"°")

        baseline = Measures.Baseline(Measures.Baselines.ITRF, 1u"km", 1u"km", 1u"km")

        @test (baseline.x += 2u"km") == 3u"km"
        @test baseline.x == 3u"km"
        @test (baseline.y += 1u"km") == 2u"km"
        @test baseline.y == 2u"km"
        @test (baseline.z -= 2u"km") == -1u"km"
        @test baseline.z == -1u"km"

        length = hypot(baseline.x, baseline.y, baseline.z)

        # Why is refdirection needed for Baseline conversion? It has no effect.
        baseline = mconvert(Measures.Baselines.J2000, baseline, refdirection, refpos, time)
        @test hypot(baseline.x, baseline.y, baseline.z) ≈ length

        uvw = Measures.UVW(Measures.UVWs.J2000, baseline, refdirection)
    end

    @testset "Doppler conversions" begin
        doppler = Measures.Doppler(Measures.Dopplers.RADIO, 20_000u"km/s")
        @test (doppler.doppler = 2) == 2
        @test doppler.doppler == 2

        doppler = Measures.Doppler(Measures.Dopplers.Z, 0.023)
        doppler = mconvert(Measures.Dopplers.RADIO, doppler)
        @test doppler.doppler == 1 - 1/(0.023 + 1)
        doppler = mconvert(Measures.Dopplers.BETA, doppler)

        # Doppler <-> Frequency
        freq = Measures.Frequency(Measures.Frequencies.LSRD, doppler, 1420u"MHz")
        @test LibCasacore.getType(LibCasacore.getRef(freq.m)) == Int(freq.type)
        doppleragain = Measures.Doppler(freq, 1420u"MHz")
        @test LibCasacore.getType(LibCasacore.getRef(doppleragain.m)) == Int(doppleragain.type)
        @test doppler ≈ doppleragain

        # Doppler <-> RadialVelocity
        rv = Measures.RadialVelocity(Measures.RadialVelocities.LSRD, doppler)
        @test rv.type == Measures.RadialVelocities.LSRD
        doppleragain = Measures.Doppler(rv)
        @test doppler ≈ doppleragain
    end
end
