# Preblema de estudo

Certa vez um professor genial da EAU-UFF me apresentou um problema de pesquisa. Ele queria uma métrica capiturasse as tendências aglomerativas de estruturas urbanas. Porém não bastava apenas um análise de vizinho mais próximo, ou uma medida de k, ele também precisava de um método que fosse sensível à formação de padrões, ou seja, padrões aglomerativos.

Sua abordagem tem como objetivo uma investigação sobre a interação entre sociedade e espaço.

"We know since Lynch that physical differences guide minds and bodies in movement. Deep physical properties can also generate affordances. A step further, the challenges of interaction and social reproduction require humans to overcome distance (Hillier and Netto, 2002)."

Então o problema de pesquisa ao fim foi: 

- Como criamos e preservamos informação no ambiente construido?
- Como capturamos essa produção de ordem nos arranjos da forma.

Ou ainda:

"The idea is to measure information as levels of order and predictability, by capturing factal dimension in cellular arrangements. The higher the fractal dimension of certain form, the more cells tend to form complex, self-similar and fractional arrangements."

# Por que a dimensão fractal (recorte metodológico)

Normalmente a dimensão de uma figura geométrica é dada por um número inteiro, uma linha tem dimensão 1, um plano dimensão 2, um cubo, 3, e assim por diante. No entanto, existem situações em que a dimensão se torna fracionária, como por exemplo: uma linha com várias mudanças de direção, um plano ou um sólido com vazios internos, um plano com protuberâncias em outras direções, entre outros.

Benoit Mandelbrot (1967; 1983) levantou a possibilidade de se definir valores fracionários à dimensão analisando o contorno de um litoral. Percebeu que, dependendo do tamanho da unidade de medida adotado, o comprimento do litoral sofria variações: quanto menor a unidade adotada, maior o valor do comprimento. Levando este processo ao extremo, no limite em que a unidade de medida tende a zero, o comprimento tende a infinito. Este problema o levou à uma outra forma de medir a dimensão de uma figura geométrica, a dimensão fractal (DF). Os objetos com dimensão fractal passaram a ser chamados de fractais.

Ou seja, conforme aumentamos os detalhes de um fenômeno, a resolução espacial aumenta.

Dentre os diferentes métodos de cálculo do DF o box-counting é o mais utilizado. Ele consiste em se colocar uma estrutura sobre uma malha de tamanho 'U' e então conta-se o número de células (ou caixas) da malha que contém parte da estrutura, isto dá um certo número 'N' que depende do tamanho 'r', isto é 'N(r)'. Em seguida diminui-se o tamanho de 'r' progressivamente e com um fator de decaimento constante (k), o que consequentemente aumenta a constagem de células ou 'N(r)'.

A partir desta contagem ajusta-se uma reta de regressão linear log x log onde o tamanho do segmento pode ser explicado pela escala de observação. Assim a dimensão fractal será o valor da inclinação da reta estimada na regressão.

A formula da dimensão fractal é:

D_0 = lim_d->inf [log(N)-log(k)] / log(r)

Aplicando o logaritmo natural para linearizar a equação:

log(N)=log(K)+(1-D)log(r)

# Processo de cálculo

## Contagem de células

A contagem de células foi realizada no ArcGIS seguindo os referentes passos:

1- Rasterização dos poligonos das edificações para os valores de celula (0.7, 3.5, 17.5, 87.5, 437.5, 2187.5)
2- Extração das celulas nulas para cada escala de análise
3- Contagem do número de celulas nulas em cada escala.

Para o primeiro passo foi arbitrado um valor mínimo de escala de 0.7 (r^-1) e aplicado um fator de multiplicação de 5 (k)*. 

Para o segundo passo foram contabilizadas as celulas nulas pois 

* Esses valores foram arbitrados, não existe uma lógica de escolha. Eu só me preocupei que o primeiro fosse menor que 1m e que k fosse menor que 10 para não gerar múltiplos muito altos.
