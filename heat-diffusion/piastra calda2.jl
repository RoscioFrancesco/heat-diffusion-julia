using Plots


function diffusione_2d(N, kappa, dt, npassi)
    h=1/(N-1)
    x = range(0.0, 1.0; length=N)
    y = range(0.0, 1.0; length=N) 
    U = zeros(N, N)
    U_new = zeros(N, N)  
    lambda = kappa * dt / h^2
    for i in range(2, N-1)
        for j in range(2, N-1)
            U[j, i] = sin(pi * x[i]) * sin(pi * y[j])
        end
    end
    for k in 1:npassi
        for i in 2:(N - 1)
            for j in 2:(N - 1)
                U_new[j, i] = U[j, i] + lambda * (
                    U[j, i + 1] +
                    U[j, i - 1] +
                    U[j + 1, i] +
                    U[j - 1, i] -
                    4 * U[j, i]
                )
            end
        end

        U, U_new = U_new, U
    end

    return x, y, U
end

x, y, U = diffusione_2d(1000, 0.1, 0.0000001, 200)
p = heatmap(
    x, y, U;
    xlabel = "x",
    ylabel = "y",
    title = "Temperatura a t = 0.2",
    colorbar_title = "Temperatura",
    aspect_ratio = :equal,
    clims = (0, 1)
)

display(p)