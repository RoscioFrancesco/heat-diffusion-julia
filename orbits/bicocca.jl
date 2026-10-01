using CairoMakie

function simula_terra_luna()
    # 1. Costanti del sistema
    m = 7.348E22  # massa Luna (kg)
    M = 5.976E24  # massa Terra (kg)
    G = 6.67E-11
    T = 2419200.0 # 28 giorni in secondi

    # 2. Parametri di simulazione
    dt = 864.0        # Passo temporale in secondi
    n_passi = 36500   # Numero di step
    
    # Pre-allocazione vettori (n_passi + 1 elementi)
    xM = zeros(n_passi + 1); yM = zeros(n_passi + 1)
    vxM = zeros(n_passi + 1); vyM = zeros(n_passi + 1)
    xm = zeros(n_passi + 1); ym = zeros(n_passi + 1)
    vxm = zeros(n_passi + 1); vym = zeros(n_passi + 1)
    xcm = zeros(n_passi + 1); ycm = zeros(n_passi + 1)

    # Condizioni Iniziali
    xM[1] = -((G * m * T^2) / (((1 + M/m)^2) * 4 * pi^2))^(1/3)
    xm[1] =  ((G * M * T^2) / (((1 + m/M)^2) * 4 * pi^2))^(1/3)
    r0 = xm[1] - xM[1]
    vyM[1] =  sqrt(G * m * abs(xM[1]) / r0^2)
    vym[1] = -sqrt(G * M * abs(xm[1]) / r0^2)
    
    # CM
    vxcm = (vxm[1] * m + vxM[1] * M) / (m + M)
    vycm = (vym[1] * m + vyM[1] * M) / (m + M)
    
    vyM[1] -= vycm
    vxM[1] -= vxcm
    vxm[1] -= vxcm
    vym[1] -= vycm
    
    xcm[1] = (xm[1] * m + xM[1] * M) / (m + M)
    ycm[1] = 0.0

    for i in 1:n_passi
        distanza_cubo = ((xM[i] - xm[i])^2 + (yM[i] - ym[i])^2)^1.5
        
        # Accelerazioni
        axM = (-G * m * (xM[i] - xm[i])) / distanza_cubo
        ayM = (-G * m * (yM[i] - ym[i])) / distanza_cubo
        axm = (-G * M * (xm[i] - xM[i])) / distanza_cubo
        aym = (-G * M * (ym[i] - yM[i])) / distanza_cubo
        
        # Aggiornamento velocità
        vxM[i+1] = vxM[i] + axM * dt
        vyM[i+1] = vyM[i] + ayM * dt
        vxm[i+1] = vxm[i] + axm * dt
        vym[i+1] = vym[i] + aym * dt
        
        # Aggiornamento posizioni
        xM[i+1] = xM[i] + vxM[i+1] * dt
        yM[i+1] = yM[i] + vyM[i+1] * dt

        xm[i+1] = xm[i] + vxm[i+1] * dt
        ym[i+1] = ym[i] + vym[i+1] * dt 
        # Centro di massa
        xcm[i+1] = (xm[i+1] * m + xM[i+1] * M) / (m + M)
        ycm[i+1] = (ym[i+1] * m + yM[i+1] * M) / (m + M)
    end
    
    return xm, ym, xM, yM, xcm, ycm
end

xm, ym, xM, yM, xcm, ycm = simula_terra_luna()

fig = Figure(size = (800, 800))

ax = Axis(fig[1, 1], title = "Sistema Terra-Luna", aspect = DataAspect(), 
          xlabel = "x (m)", ylabel = "y (m)")

lines!(ax, xm, ym, label = "Luna", color = :gray, linewidth = 1)
lines!(ax, xM, yM, label = "Terra", color = :blue, linewidth = 2)
lines!(ax, xcm, ycm, label = "Centro di Massa", color = :red, linestyle = :dash)

axislegend(ax)
display(fig)