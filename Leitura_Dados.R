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
setwd("C:\\Users\\Marcos\\Desktop\\Base de Segregação\\Retificação")

################################################################################
############################################# Leitura de banco de dados fractais 
################################################################################

setwd("E:\\Arquivos Maíra\\Desktop\\Base de Segregação\\Retificação")
Fractal<- read.csv("T_Fractal.csv", head = T, sep = ";")
Fractal<-transform(Fractal, Name=factor(Name),
                   r = (1/Cell))
Basico<-read.csv("dados_basicos.csv", head = T, sep = ";")
Fractal<-merge(Fractal, Basico, by.x = "Name", by.y = "ID", all.x = T)

################################################################################
############################################ configuração dos temas dos gráticos
################################################################################

# Tema colorido
tema<-theme(legend.key = element_rect(fill="White"),
            panel.background = element_rect(fill = "White"),
            axis.line = element_line(color = "grey23"),
            panel.grid.major.y = element_line (color = "grey90"),
            panel.grid.major.x = element_line (color = "grey95"),
            panel.grid.minor.y = element_line (color = NA),
            panel.grid.minor.x = element_line (color = "grey95"))

# Tema colorido boxplot
temabox<-theme(legend.position = "none",
               panel.background = element_rect(fill = "White"),
               axis.line = element_line(color = "grey23"),
               panel.grid.major.y = element_line (color = "grey90"),
               panel.grid.major.x = element_line (color = "grey95"),
               panel.grid.minor.y = element_line (color = NA),
               panel.grid.minor.x = element_line (color = "grey95"))

# Tema preto e branco
temaPB<-theme(legend.key = element_rect(fill="White"),
              panel.background = element_rect(fill = NA),
              axis.line = element_line(color = "grey23"),
              panel.grid.major.y = element_line (color = "grey95"),
              panel.grid.major.x = element_line (color = "grey95"),
              panel.grid.minor.y = element_line (color = NA),
              panel.grid.minor.x = element_line (color = "grey95"))

cores<- c("steelblue3","goldenrod1","indianred1")
cinza<- c("grey83", "grey52", "black")


################################################################################
############################################################# Cálculo do Fractal 
################################################################################

#Usando Cell
FUN<-function(x){
  glm(COUNT ~ Cell, family = poisson (link = "log"), data = x)
  }
teste<-by(Fractal, Fractal$Name, FUN)
head(teste)

coef<-lapply(teste, coefficients)
coef<-as.data.frame(coef)
coef<-as.data.frame(t(coef))
write.csv(coef, "teste.csv")
DF<-read.csv("teste.csv", head = T, sep = ",")
library(stringi)
DF["X"] <- stri_sub(DF$X,2,4)


DF<- transform(DF, DF=(1-Cell))

### Fim do cálculo da dimensão fractal

################################################################################
################################################ Análises Gráficas Exploratórias 
################################################################################

ggplot(Fractal[Fractal$RENDA == 1 |Fractal$RENDA == 2 | Fractal$RENDA == 3 , ], aes(log(Cell),log(COUNT)))+
  geom_point(aes(color = factor(RENDA)))+
  geom_line(aes(color = factor(RENDA),fill = factor(Name)))

