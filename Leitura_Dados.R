################################################################################
######################################### Configurações globais pacotes e pastas
################################################################################

#Limpa o ambiente
rm(list = ls())

#Configurações Gerais dos Dígitos
options(digits = 5)

#pacotes para MLG
library(ggplot2)
library(xtable)
library(gridExtra)
library(devtools)
library(psych)
library(maptools)
library(osmar)
library(plotly)
library(GISTools)
library(rgdal)

# Pasta de referência (A pasta aonde seus arquivos estão e serão salvos. Sempre separe por "\\")
setwd(getwd())

################################################################################
####################################################### Extração de dados do OSM 
################################################################################

############################### Definição dos parâmetros das cidades de trabalho

# Escolha da escala do mapa
size<-1000

#escolha a caixa de exportação do local a se trabalhar

## Paris
paris_lon<-2.338202
paris_lat<-48.873912

## Rome
rome_lon<-12.500969
rome_lat<-41.911136

## Rio
rio_lon<- -43.203816
rio_lat<- -22.983794

## New York
ny_lon<--73.990020 
ny_lat<-40.743726

# Função de delimitação da área dos mapas
a_map<-function(x, y) {center_bbox(x, y, size, size)}

# Aplicação da função
paris<-a_map(paris_lon,paris_lat)
rome<-a_map(rome_lon,rome_lat)
rio<-a_map(rio_lon,rio_lat)
ny<-a_map(ny_lon,ny_lat)

############################################################# acessando os dados

#definindo o caminho da api
src <- osmsource_api()

#baixando os mapas do OSM
paris <- get_osm(paris, source = src)
rome <- get_osm(rome, source = src)
rio <- get_osm(rio, source = src)
ny <- get_osm(ny, source = src)


################################################# extração de poligonos e linhas

#função de estração dos prédios
bg_func<-function (x){
  bg_ids <- find(x, way(tags(k == "building")))
  bg_ids <- find_down(x, way(bg_ids))
  bg <- subset(x, ids = bg_ids)
  bg_poly <- as_sp(bg, "polygons")
}
#função de estração das ruas
hw_func<-function (x){
  hw_ids <- find(x, way(tags(k == "highway")))
  hw_ids <- find_down(x, way(hw_ids))
  hw <- subset(x, ids = hw_ids)
  hw_line <- as_sp(hw, "lines")
}

# Extraindo os poligonos das cidades
ny_poly<-bg_func(ny)
rio_poly<-bg_func(rio)
rome_poly<-bg_func(rome)
paris_poly<-bg_func(paris)

# Estraindo as linhas das cidades
ny_line<-hw_func(ny)
rio_line<-hw_func(rio)
rome_line<-hw_func(rome)
paris_line<-hw_func(paris)

############################################################## plotando os mapas

par(mfrow = c(2, 2))

#New York
plot(ny_poly, col = "gray", main='New York')
plot(ny_line, add = TRUE, col = "light gray")

#Rio
plot(rio_poly, col = "gray", main='Rio de Janeiro')
plot(rio_line, add = TRUE, col = "light gray")

#Roma
plot(rome_poly, col = "gray", main='Rome')
plot(rome_line, add = TRUE, col = "light gray")

#Paris
plot(paris_poly, col = "gray", main='Paris')
plot(paris_line, add = TRUE, col = "light gray")

par(mfrow=c(1,1))

################################################################ salvando em SHP

# New York
writeOGR(obj=ny_poly, dsn="ny_builgings", layer="ny_builgings", driver="ESRI Shapefile")
writeOGR(obj=ny_line, dsn="ny_streets", layer="ny_streets", driver="ESRI Shapefile")

# Rio de Janeiro
writeOGR(obj=rio_poly, dsn="rio_builgings", layer="rio_builgings", driver="ESRI Shapefile")
writeOGR(obj=rio_line, dsn="rio_streets", layer="rio_streets", driver="ESRI Shapefile")

# Paris
writeOGR(obj=paris_poly, dsn="paris_builgings", layer="paris_builgings", driver="ESRI Shapefile")
writeOGR(obj=paris_line, dsn="paris_streets", layer="paris_streets", driver="ESRI Shapefile")

# Rome
writeOGR(obj=rome_poly, dsn="rome_builgings", layer="rome_builgings", driver="ESRI Shapefile")
writeOGR(obj=rome_line, dsn="rome_streets", layer="rome_streets", driver="ESRI Shapefile")

################################################################################
############################################ Aplicação do método de box-counting 
################################################################################

#
#
#
#

# Por enquanto esta etapa está sendo desenvolvida no ArcMAP. Em breve
# prosseguirei com o desenvolvimoento em R.

#
#
#
#


################################################################################
############################################# Leitura de banco de dados fractais 
################################################################################


Fractal<- read.csv("T-fractal.csv", head = T, sep = ";")
colnames(Fractal)<-c('COUNT','NAME','CELL')
Fractal<-transform(Fractal, r = (1/CELL))

################################################################################
############################################################# Cálculo do Fractal 
################################################################################

#Usando Cell
FUN<-function(x){
  glm(COUNT ~ CELL, family = poisson (link = "log"), data = x)
  }
teste<-by(Fractal, Fractal$NAME, FUN)
head(teste)

coef<-lapply(teste, coefficients)
coef<-as.data.frame(coef)
coef<-as.data.frame(t(coef))
write.csv(coef, "teste.csv")
DF<-read.csv("teste.csv", head = T, sep = ",")
colnames(DF) <- c("X", "Intercepto", "Estimador_CELL")

DF<- transform(DF, DF=(log(Intercepto)/log(5)))
DF<-read.csv("DF.csv", head = T, sep = ",")
### Fim do cálculo da dimensão fractal

################################################################################
################################################ Análises Gráficas Exploratórias 
################################################################################

ggplot(Fractal, aes(CELL,log(COUNT)))+
  geom_point(aes(color = factor(NAME)))+
  geom_line(aes(color = factor(NAME),fill = factor(NAME)))