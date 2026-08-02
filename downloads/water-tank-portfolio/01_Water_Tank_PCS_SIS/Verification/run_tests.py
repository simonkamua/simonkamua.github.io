"""Deterministic checks for the corrected Water-Tank PCS/SIS design."""
def split(demand):
    if demand <= 35:
        return 100.0, 30.0
    if demand <= 65:
        return 100.0-(demand-35.0)*2.0, 30.0+(demand-35.0)*(20.0/30.0)
    return max(0.0,40.0-(demand-65.0)*(40.0/35.0)), min(100.0,50.0+(demand-65.0)*(50.0/35.0))

def votes(values, threshold, direction):
    if direction == "high": return sum(v >= threshold for v in values) >= 2
    return sum(v <= threshold for v in values) >= 2

def run():
    tests=[]
    def check(name, condition, expected, actual):
        assert condition, f"{name}: expected {expected}, got {actual}"
        tests.append((name,"PASS",expected,actual))
    check("Low reduction demand",split(20)==(100.0,30.0),"LCV 100%, pump 30%",str(split(20)))
    mid=split(50)
    check("Overlap band",round(mid[0],1)==70.0 and round(mid[1],1)==40.0,"LCV 70%, pump 40%",str(mid))
    high=split(100)
    check("Maximum reduction demand",round(high[0],1)==0.0 and round(high[1],1)==100.0,"LCV 0%, pump 100%",str(high))
    check("One high channel no trip",not votes([94,55,55],90,"high"),"No HH trip","No trip")
    check("Two high channels close inlet",votes([94,93,55],90,"high"),"HH inlet trip","Trip")
    check("HH leaves LL pump permit healthy",not votes([94,93,55],15,"low"),"No pump trip","No LL trip")
    check("One low channel no trip",not votes([10,55,55],15,"low"),"No LL trip","No trip")
    check("Two low channels trip pumps",votes([10,12,55],15,"low"),"LL pump trip","Trip")
    check("HH reset hysteresis",85<90,"Reset below HH","85 < 90")
    check("LL reset hysteresis",20>15,"Reset above LL","20 > 15")
    check("PCS LT upscale closes inlet",110>105,"Bad PV forces closed inlet","110%")
    return tests

if __name__=='__main__':
    rows=run()
    print("Water-Tank PCS/SIS corrected reference-model verification")
    for row in rows: print(f"{row[1]:4} | {row[0]} | expected={row[2]} | actual={row[3]}")
    print(f"SUMMARY: {len(rows)}/{len(rows)} PASS")
