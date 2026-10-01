using Pkg
Pkg.activate(@__DIR__)

using LinearAlgebra
using CairoMakie

# Forza esercitata da M su m
function forza_gravitazionale(r_m, r_M, m, M, G)
    d = r_M - r_m
    distanza = norm(d)
    return (G * m * M / distanza^3) * d
end

function simula_due_corpi(
    m, M, G,
    r_m0, r_M0,
    v_m0, v_M0,
    dt, N
)
    pos_m = zeros(2, N + 1)
    pos_M = zeros(2, N + 1)

    # pos iniziali
    pos_m[1, 1] = r_m0[1]
    pos_m[2, 1] = r_m0[2]
    pos_M[1, 1] = r_M0[1]
    pos_M[2, 1] = r_M0[2]   

    # Forza iniziale
    F0 = forza_gravitazionale(r_m0, r_M0, m, M, G)

    # acc iniziali
    ax_m0 = F0[1] / m
    ay_m0 = F0[2] / m

    ax_M0 = -F0[1] / M
    ay_M0 = -F0[2] / M

    # riempio la colonna 2
    pos_m[1, 2] = r_m0[1] + v_m0[1] * dt + ax_m0 * dt^2 / 2
    pos_m[2, 2] = r_m0[2] + v_m0[2] * dt + ay_m0 * dt^2 / 2

    pos_M[1, 2] = r_M0[1] + v_M0[1] * dt + ax_M0 * dt^2 / 2
    pos_M[2, 2] = r_M0[2] + v_M0[2] * dt + ay_M0 * dt^2 / 2

    for k in 2:N

        # Posizioni attuali dei due corpi: [x, y]
        r_m = [pos_m[1, k], pos_m[2, k]]
        r_M = [pos_M[1, k], pos_M[2, k]]

        # Forza esercitata sul corpo m
        F = forza_gravitazionale(r_m, r_M, m, M, G)

        Fx = F[1]
        Fy = F[2]

        # Accelerazione del corpo m
        ax_m = Fx / m
        ay_m = Fy / m
        ax_M = -Fx / M
        ay_M = -Fy / M

        # Nuova posizione del corpo m
        pos_m[1, k+1]=2*pos_m[1, k]-pos_m[1, k-1]+ax_m*dt^2
        pos_m[2, k+1]=2*pos_m[2, k]-pos_m[2, k-1]+ay_m*dt^2

        # Nuova posizione del corpo M
        pos_M[1, k+1]=2*pos_M[1, k]-pos_M[1, k-1]+ax_M*dt^2
        pos_M[2, k+1]=2*pos_M[2, k]-pos_M[2, k-1]+ay_M*dt^2
    end
    return pos_m, pos_M
end

G = 1.0
m = 1
M = 5.0

d = 1
dt = 0.001
N = 8000

# Posizioni con baricentro nell'origine
r_m0 = [-M / (m + M) * d, 0.0]
r_M0 = [ m / (m + M) * d, 0.0]

omega = sqrt(G * (m + M) / d^3)

# 1.0: orbite circolari; 0.8: orbite ellittiche
fattore = 0.8

v_m0 = [0.0, fattore * omega * r_m0[1]]
v_M0 = [0.0, fattore * omega * r_M0[1]]

pos_m, pos_M = simula_due_corpi(
    m, M, G,
    r_m0, r_M0,
    v_m0, v_M0,
    dt, N
)
fig = CairoMakie.Figure(size = (800, 800))

ax = CairoMakie.Axis(
    fig[1, 1],
    title = "Problema gravitazionale dei due corpi",
    xlabel = "x (adimensionale)",
    ylabel = "y (adimensionale)",
    aspect = CairoMakie.DataAspect()
)

CairoMakie.lines!(
    ax, pos_m[1, :], pos_m[2, :];
    label = "Corpo m",
    color = :royalblue,
    linewidth = 2
)

CairoMakie.lines!(
    ax, pos_M[1, :], pos_M[2, :];
    label = "Corpo M",
    color = :orange,
    linewidth = 2
)

CairoMakie.scatter!(
    ax, [0.0], [0.0];
    label = "Baricentro",
    color = :red,
    marker = :cross,
    markersize = 15
)

CairoMakie.axislegend(ax)

percorso = joinpath(@__DIR__, "due_corpi.png")
CairoMakie.save(percorso, fig)

display(fig)
println("Grafico salvato in: ", percorso)