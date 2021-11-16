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

using CSV
# Automating the download of V-U Data from FRED to csv format:
function downloadFred()
    url = "https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=on&txtcolor=%23444444&ts=12&tts=12&width=1168&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=DHIDFHVTUR&scale=left&cosd=2001-01-01&coed=2018-04-01&line_color=%234572a7&link_values=false&line_style=solid&mark_type=none&mw=3&lw=2&ost=-99999&oet=99999&mma=0&fml=a&fq=Monthly&fam=avg&fgst=lin&fgsnd=2018-04-01&line_index=1&transformation=lin&vintage_date=2021-11-13&revision_date=2021-11-13&nd=2001-01-01"
    download(url, "Data/VURatio.csv")
end

