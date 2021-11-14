# Automating the download of CPS Basic Data from NBER
# Becareful to set the right location

function downloadCPSB()
    url = "https://data.nber.org/cps-basic2/dta/"
    k = "cpsb"
    for i in 1989:2020
        for j in 1:12
            if j < 10
            download(url*k*string(i)*"0"*string(j)*".dta", "Data/"*string(i)*"0"*string(j)*".dta")
            else
            download(url*k*string(i)*string(j)*".dta", "Data/"*string(i)*string(j)*".dta")
            end
        end
    end
end

downloadCPSB()

