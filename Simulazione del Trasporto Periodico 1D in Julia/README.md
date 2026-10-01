# Trasporto periodico monodimensionale

Simulazione dell’equazione di trasporto lineare in una dimensione, realizzata in **Julia** con uno **schema upwind esplicito del primo ordine** e condizioni al contorno periodiche. Il grafico, generato con **CairoMakie**, confronta la soluzione numerica con quella esatta dopo un periodo completo.

## Modello matematico

Si considera l’equazione:

$$
\frac{\partial u}{\partial t} + c\frac{\partial u}{\partial x} = 0,
\qquad x\in[0,1),\quad t\geq 0,
$$

dove $u(x,t)$ rappresenta la concentrazione di una quantità trasportata e $c$ è la velocità costante di trasporto. Per $c>0$, il profilo si sposta verso destra.

Le condizioni periodiche identificano i due estremi del dominio:

$$
u(x+1,t)=u(x,t).
$$

La condizione iniziale è:

$$
u(x,0)=1+0.5\sin(2\pi x).
$$

La soluzione esatta è una traslazione del profilo iniziale, senza variazioni di forma o ampiezza:

$$
u(x,t)=1+0.5\sin\bigl(2\pi(x-ct)\bigr).
$$

## Metodo numerico

Il dominio è discretizzato con $N$ punti equidistanti, con passo $\Delta x=1/N$. La griglia comprende $x=0$ ed esclude $x=1$, che coincide con il primo punto per periodicità.

La derivata temporale è approssimata con Eulero esplicito e quella spaziale con una differenza all’indietro, coerente con una velocità positiva:

$$
u_i^{n+1}=u_i^n-C\left(u_i^n-u_{i-1}^n\right),
\qquad C=\frac{c\Delta t}{\Delta x}.
$$

Il parametro $C$ è il **numero di Courant**. Per lo schema implementato, la condizione di stabilità è:

$$
0\leq C\leq 1.
$$

Per il primo punto della griglia, il valore precedente è quello dell’ultimo punto: nel codice, quando `i == 1`, si pone `precedente = N`.

I vettori `u` e `u_new` mantengono separati i valori al tempo corrente e quelli al passo successivo. Dopo ogni aggiornamento vengono scambiati, evitando che i valori appena calcolati influenzino gli altri punti dello stesso passo.

**La discretizzazione attuale è pensata per $c\geq 0$.** Con velocità negativa occorre usare il punto successivo e una differenza in avanti.

## Parametri della simulazione

| Parametro | Significato | Valore |
|---|---|---:|
| `N` | Numero di punti della griglia | 100 |
| `c` | Velocità di trasporto | 1.0 |
| `dt` | Passo temporale | 0.008 |
| `npassi` | Numero di passi temporali | 125 |
| $\Delta x$ | Passo spaziale | 0.01 |
| $C$ | Numero di Courant | 0.8 |
| $T$ | Tempo finale, `dt * npassi` | 1.0 |

La simulazione viene eseguita con:

```julia
x, u_finale = trasporto(100, 1.0, 0.008, 125)
```

La funzione restituisce la griglia spaziale `x` e la concentrazione finale `u_finale`.

## Risultato e interpretazione

Con $c=1$ e $T=1$, il profilo percorre l’intera lunghezza del dominio e torna alla posizione iniziale. La soluzione esatta finale coincide quindi con la condizione iniziale.

Il grafico confronta:

- **Linea continua:** condizione iniziale, coincidente con la soluzione esatta a $T=1$.
- **Linea tratteggiata:** soluzione numerica dopo 125 passi.

Per questi parametri, lo schema upwind introduce **diffusione numerica**: l’ampiezza dell’onda diminuisce leggermente, pur in assenza di diffusione nel modello matematico. Il confronto mostra quindi l’effetto dell’approssimazione numerica sul trasporto del profilo.

![Confronto tra soluzione esatta e numerica del trasporto periodico](trasporto.png)

Lo script salva `trasporto.png` nella propria cartella tramite `joinpath(@__DIR__, "trasporto.png")`. Per visualizzare l’immagine anche su GitHub, caricarla nella stessa cartella di questo README.

## Esecuzione

Salvare il programma come `trasporto.jl`. Con Julia installato, aprire un terminale nella cartella del programma e installare CairoMakie nell’ambiente locale:

```bash
julia --project=. -e 'using Pkg; Pkg.add("CairoMakie")'
```

Se la cartella contiene già un `Project.toml` con CairoMakie tra le dipendenze, preparare invece l’ambiente con:

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

Eseguire quindi:

```bash
julia --project=. trasporto.jl
```

Lo script produce il grafico e lo salva in formato PNG. La visualizzazione tramite `display(fig)` dipende dall’ambiente di esecuzione; il file salvato può essere aperto separatamente.

## Modifica dei parametri

Per provare altre risoluzioni o durate, modificare gli argomenti della funzione `trasporto(N, c, dt, npassi)`, rispettando la condizione di stabilità. Se si aumenta `N` mantenendo `c>0`, il passo temporale deve soddisfare `dt <= 1 / (N * c)`.

Se si cambiano `c`, `dt` o `npassi`, aggiornare anche il titolo, le etichette e la curva di riferimento. Per un tempo finale generico $T$, la soluzione esatta sulla griglia è:

```julia
u_esatta = 1 .+ 0.5 .* sin.(2 * pi .* (x .- c * T))
```

## Riferimenti

- [Makie: installazione e primo grafico](https://docs.makie.org/stable/tutorials/getting-started.html)
- [Julia Pkg: gestione degli ambienti](https://pkgdocs.julialang.org/v1/environments/)
- [Fundamentals of Numerical Computation: upwinding e stabilità](https://fncbook.com/upwind/)
