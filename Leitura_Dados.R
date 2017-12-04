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

# Pasta de referência (A pasta aonde seus arquivos estão e serão salvos. Sempre separe por "\\")
setwd("C:\\Users\\Maíra Pinheiro\\Downloads")

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