# Planificador de Procesos con Colas Multinivel

Simulación de tres algoritmos de planificación de CPU: **Round Robin**, **Prioridades Apropiativo** y **MLFQ**. Se comparan sus métricas de rendimiento sobre un mismo caso de prueba y se analiza la complejidad de cada implementación.

---

## Índice

1. [Conceptos base](#1-conceptos-base)
2. [Algoritmos simulados](#2-algoritmos-simulados)
3. [Caso de prueba y tablas de tiempos](#3-caso-de-prueba-y-tablas-de-tiempos)
4. [Comparación de resultados](#4-comparación-de-resultados)
5. [Análisis de complejidad Big-O](#5-análisis-de-complejidad-big-o)
6. [Conclusión](#6-conclusión)

---

## 1. Conceptos base

Un **planificador de procesos** es el componente del sistema operativo que decide cuál proceso usa la CPU en cada momento. Gestiona una o varias colas de procesos listos y elige el siguiente según una política definida.

Cada proceso se representa con los siguientes atributos:

- **PID**: identificador único.
- **AT (Arrival Time)**: momento en que llega al sistema.
- **BT (Burst Time)**: ráfaga de CPU requerida.
- **Prioridad** (solo para el algoritmo de prioridades).

<p align="center">
  <img src="./image1.png" width="600">
</p>

El flujo de estados de un proceso (nuevo -> listo -> corriendo -> terminado) se muestra en el siguiente diagrama:

<p align="center">
  <img src="./image2.png" width="600">
</p>

Las tres métricas que se calculan para cada proceso son:

| Métrica | Fórmula | Qué mide |
|---------|---------|----------|
| **Tiempo de retorno (TAT)** | Finalización -- Llegada | Tiempo total desde que llega hasta que termina |
| **Tiempo de espera (WT)** | TAT -- Ráfaga | Tiempo que el proceso espera en cola sin CPU |
| **Tiempo de respuesta (RT)** | Primera\_CPU -- Llegada | Cuándo recibe su primer turno de CPU |

---

## 2. Algoritmos simulados

### Round Robin (RR)

Cola circular FIFO con quantum fijo. Si un proceso no termina en su quantum, regresa al final de la cola. Sin riesgo de inanición.

<p align="center">
  <img src="./image3.png" width="600">
</p>

### Prioridades Apropiativo

Cola ordenada por prioridad (número más bajo = mayor prioridad). Si llega un proceso con mayor prioridad que el que está corriendo, lo expulsa inmediatamente. Riesgo de inanición para procesos de baja prioridad (se resuelve con envejecimiento).

<p align="center">
  <img src="./image4.png" width="600">
</p>

### Multinivel Retroalimentado (MLFQ)

Tres colas independientes con quantum decreciente. Los procesos nuevos entran a la cola de mayor prioridad; si agotan su quantum, bajan de nivel. Un boost periódico mueve todos los procesos a Cola 0 para evitar inanición.

| Cola | Quantum | Política |
|------|---------|----------|
| Cola 0 | 2 | Mayor prioridad |
| Cola 1 | 4 | Prioridad media |
| Cola 2 | sin límite | FCFS |

Reglas de funcionamiento:
1. Se ejecuta el proceso de la cola no vacía con mayor prioridad.
2. Dentro de la misma cola se usa Round Robin.
3. Proceso nuevo entra a Cola 0.
4. Si agota su quantum, baja una cola.
5. Cada 10 unidades de tiempo (boost), todos suben a Cola 0.

<p align="center">
  <img src="./image5.png" width="600">
</p>

El archivo `PlanificadorDeProcesosConColasMultinivel.psc` contiene la implementación en pseudocódigo estructurado:

- `EjecutarRoundRobin`
- `EjecutarPrioridades`
- `EjecutarMLFQ`
---

## 3. Caso de prueba y tablas de tiempos

Se usa el mismo conjunto de procesos para los tres algoritmos:

| Proceso | AT | BT | Prioridad |
|---------|----|----|-----------|
| P1 | 0 | 5 | 2 |
| P2 | 1 | 3 | 1 |
| P3 | 2 | 2 | 3 |

> La columna Prioridad solo aplica al algoritmo de Prioridades Apropiativo.

### RR (quantum = 3)

**Gantt:** `P1(0-3) -> P2(3-6) -> P3(6-8) -> P1(8-10)`

| Proceso | AT | BT | FT | TAT | WT | RT |
|--------|----|----|----|-----|----|-----|
| P1 | 0 | 5 | 10 | 10 | 5 | 0 |
| P2 | 1 | 3 | 6  | 5  | 2 | 2 |
| P3 | 2 | 2 | 8  | 6  | 4 | 4 |
| **Promedio** | --- | --- | --- | **7.00** | **3.67** | **2.00** |

### Prioridades Apropiativo

**Gantt:** `P1(0-1) -> P2(1-4) -> P1(4-8) -> P3(8-10)`

> P2 expulsa a P1 en t=1 por tener prioridad 1 < 2. P3 espera hasta que terminan ambos.

| Proceso | AT | BT | FT | TAT | WT | RT |
|--------|----|----|----|-----|----|-----|
| P1 | 0 | 5 | 8  | 8  | 3 | 0 |
| P2 | 1 | 3 | 4  | 3  | 0 | 0 |
| P3 | 2 | 2 | 10 | 8  | 6 | 6 |
| **Promedio** | --- | --- | --- | **6.33** | **3.00** | **2.00** |

### MLFQ (q0=2, q1=4, q2=sin límite, boost=10)

**Gantt:** `P1(0-2)[Q0] -> P2(2-4)[Q0] -> P3(4-6)[Q0] -> P1(6-9)[Q1] -> P2(9-10)[Q1]`

> P1 agota el quantum=2 en Cola 0 y baja a Cola 1. P2 y P3 terminan sin agotar su quantum.

| Proceso | AT | BT | FT | TAT | WT | RT |
|--------|----|----|----|-----|----|-----|
| P1 | 0 | 5 | 9  | 9  | 4 | 0 |
| P2 | 1 | 3 | 10 | 9  | 6 | 1 |
| P3 | 2 | 2 | 6  | 4  | 2 | 2 |
| **Promedio** | --- | --- | --- | **7.33** | **4.00** | **1.00** |

---

## 4. Comparación de resultados

| Algoritmo | TAT promedio | WT promedio | RT promedio |
|-----------|-------------|------------|------------|
| Round Robin (q=3) | 7.00 | 3.67 | 2.00 |
| Prioridades Apropiativo | **6.33** | **3.00** | 2.00 |
| MLFQ | 7.33 | 4.00 | **1.00** |

- **Mejor TAT y WT: Prioridades (6.33 / 3.00).** P2 desaloja a P1 al llegar, termina rápido y reduce el retorno global. Favorece las tareas urgentes a costa de postergar las de baja prioridad.
- **Mejor RT: MLFQ (1.00).** Todos los procesos nuevos entran a Cola 0 con quantum pequeño, por lo que reciben su primer turno de CPU muy rápido. Ideal para sistemas interactivos.
- **Round Robin (7.00 / 3.67 / 2.00).** El más equitativo: ningún proceso espera demasiado, pero tampoco favorece a los más cortos ni a los más urgentes.

---

## 5. Análisis de complejidad Big-O

Antes de entrar algoritmo por algoritmo, hay dos variables clave que aparecen en todos:

- **n** -> cantidad de procesos
- **T** -> tiempo total de simulación (la suma de todas las ráfagas)

La razón por la que T importa tanto es que la simulación **avanza segundo a segundo**: en cada tick del reloj recorre los `n` procesos para ver si alguno llegó o terminó. Eso hace que el costo base de cualquiera de los tres algoritmos sea **O(n · T)**.

---

### Round Robin

La cola funciona con dos punteros (`frente` y `finCola`) que avanzan en O(1), así que encolar y desencolar son instantáneos. El único trabajo real que se hace en cada tick es revisar los `n` procesos dos veces: una antes de ejecutar y otra mientras el proceso corre. Eso da **O(n · T)**.

---

### Prioridades Apropiativo

Acá la cola no es un simple FIFO: cada vez que entra un proceso nuevo, el código lo inserta en su posición correcta moviendo elementos (insertion sort). Y cada vez que se saca el proceso de mayor prioridad, desplaza todo el arreglo un lugar hacia adelante.

Eso tiene un costo mayor por operación, pero el insertion sort solo ocurre cuando llega un proceso nuevo (exactamente `n` veces en toda la simulación) así que su costo total es O(n²), no O(n² · T) como podría parecer a primera vista. El desplazamiento al desencolar sí ocurre en cada tick, sumando O(n · T). En total: **O(n² + n · T)**, que simplifica a **O(n · T)** porque T siempre es mayor o igual a n.

El algoritmo termina siendo del mismo orden que Round Robin, aunque en la práctica hace más trabajo por tick porque mantiene el orden de la cola en todo momento.

---

### MLFQ

Tiene tres colas FIFO separadas, pero cada una opera igual que la de Round Robin: enqueue y dequeue en O(1). Elegir cuál cola usar es simplemente un `if-else` de tres casos, también O(1).

Lo único extra es el **boost periódico**: cada 10 ticks mueve todos los procesos de las colas inferiores a la Cola 0. Eso cuesta O(n) cada vez que ocurre, y ocurre T/10 veces en total -> O(n · T/10). Como 10 es una constante, esto no cambia el orden: sigue siendo **O(n · T)**.

---

### Resumen

| Algoritmo | Complejidad total | Complejidad espacial |
|-----------|:-----------------:|:--------------------:|
| Round Robin | O(n · T) | O(n) |
| Prioridades Apropiativo | O(n · T) | O(n) |
| MLFQ | O(n · T) | O(n) |

Los tres dan el mismo resultado asintótico. La diferencia real está en cuánto trabajo hacen por tick: Round Robin y MLFQ son los más livianos, mientras que Prioridades hace un poco más por el mantenimiento del orden en la cola. En un sistema operativo real, usar un min-heap en lugar del arreglo ordenado reduciría ese costo a O(log n) por inserción, pero para los fines de esta simulación las diferencias son despreciables.

---

## 6. Conclusión

La elección de la estructura de colas y la política de planificación afectan directamente el rendimiento percibido. Prioridades minimiza el tiempo de espera total; MLFQ logra el mejor tiempo de respuesta para procesos interactivos; Round Robin ofrece el trato más equitativo.

La complejidad O(n·T) de la simulación contrasta con la eficiencia O(log n) que se lograría en un sistema operativo real usando montículos o colas circulares optimizadas.
