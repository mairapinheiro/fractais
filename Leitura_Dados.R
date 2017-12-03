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
##################################################### leitura e correção dos csv 
# Não precisa rodar isso.
################################################################################

# Leitura do Banco por ponto de permanência
Pontos<-read.csv(file="Pontos.csv",head=TRUE,sep=";")
Pontos<- transform(Pontos, RENDA = factor(RENDA))
str(Pontos)
Pontos<-Pontos[!(Pontos$RENDA == 9)|(Pontos$DIST_CBD >= 80000),]
head(Pontos)

# Leitura do banco por indivíuo levantado
dadosID <- read.csv(file="Compilacao.csv",head=TRUE,sep=";")
str(dadosID)
dadosID<-dadosID[!(dadosID$RENDA == 4 | dadosID$RENDA == 9),]
dadosID<-transform(dadosID, RENDA=factor(RENDA),
                   POSSUI_AUTOMOVEL=factor(POSSUI_AUTOMOVEL),
                   ID=factor(ID))
dadosID<-dadosID[order(dadosID$ID),]
head(dadosID)

# Entropia
entropia<- read.csv("Entropia.csv", head=T, sep=";")
dadosID<-merge(dadosID, entropia, by.x = "ID", by.y = "ID_MAIRA", all.x = TRUE)
entropia<-merge(entropia, dadosID,by.x = "ID_MAIRA", by.y = "ID", all.x = TRUE)

#### Criação das variáveis
dadosID<-cbind(dadosID, ATV.SEG=(dadosID$ATIVIDADES/dadosID$SEGMENTOS))
dadosID<-cbind(dadosID, EXT_2=((dadosID$EXTENSAO^2)))

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
# roda tudo sem pensar
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
################################################ Análises Gráficas exploratórias
# Só teste
################################################################################

Pontos$RENDA <- factor(Pontos$RENDA,
                        levels = c(1,2,3),
                        labels = c("Lower", "Middle", "Higher")) 

# Gráfico das horas x distancia cbd todos por Renda
PlotHorasRenda<-ggplot(Pontos, aes(HORA, DIST_CBD, color=RENDA, group=ID_MAIRA))+
  geom_point()+
  geom_line(size = 0.1, ALPHA = 0.5)+
  scale_color_manual(values = cores)+
  labs(ggtitle = "Income Groups", x = "Time", y = "Distance to CBD")

PlotHorasRenda + facet_grid(RENDA ~ .) + tema


# Gráfico das horas x distancia cbd todos por Renda PB
PlotHorasRendaPB<-ggplot(Pontos, aes(HORA, DIST_CBD , color=RENDA, group=ID_MAIRA))+
  geom_point()+
  geom_line(size = 0.1, ALPHA = 0.5)+ 
  scale_color_manual(name = "Income Groups", values = cinza)+
  labs(ggtitle = "Income Groups", x = "Time", y = "Distance to CBD")
  
PlotHorasRendaPB + facet_grid(RENDA ~ .) + temaPB



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
################################ merge com as demais informações do questionário 
################################################################################

dadosID<-merge(dadosID, DF, by.x = "ID", by.y = "X", all.x = TRUE)
dadosID<- transform(dadosID, DF_Atv=(DF^ATIVIDADES))

dadosID2<-na.omit(dadosID)

dadosID$RENDA <- factor(dadosID$RENDA,
                        levels = c(1,2,3),
                        labels = c("Lower", "Middle", "Higher")) 

dadosID<- transform(dadosID, RENDA=as.numeric(as.factor(RENDA)))

################################################################################
####################################################################### Box-plot 
################################################################################

# Boxplot coloridos
plot1<-ggplot(dadosID2, aes(factor(RENDA), EXTENSAO))+
  geom_boxplot(fill = cores)+
  labs(ggtitle = "Income Groups", x = "Income Groups", y = "Extension of paths (m)")+
  scale_fill_identity(guide = "legend")

plot2<-ggplot(dadosID2, aes(factor(RENDA), ATIVIDADES))+
  geom_boxplot(fill = cores)+
  labs(ggtitle = "Income Groups", x = "Income Groups", y = "Number of Activities")+
  scale_fill_identity(guide = "legend")

plot3<-ggplot(dadosID2, aes(factor(RENDA), SEGMENTOS))+
  geom_boxplot(fill = cores)+
  labs(ggtitle = "Income Groups", x = "Income Groups", y = "Number of Segments")+
  scale_fill_identity(guide = "legend")

plot4<-ggplot(dadosID2, aes(factor(RENDA), DF_Atv))+
  geom_boxplot(fill = cores)+
  labs(ggtitle = "Income Groups", x = "Income Groups", y = "Mobility")+
  scale_fill_identity(guide = "legend")

grid.arrange(plot1+temabox, plot2+temabox, plot3+temabox, plot4+temabox, nrow=2, ncol=2)

plot1



# Boxplot P&B
plot1<-ggplot(dadosID2, aes(factor(RENDA), EXTENSAO))+
  geom_boxplot(fill = cinza)+
  labs(ggtitle = "Income Groups", x = "Income Groups", y = "Extension of paths (m)")+
  scale_fill_identity(guide = "legend")

plot1

plot2<-ggplot(dadosID2, aes(factor(RENDA), ATIVIDADES))+
  geom_boxplot(fill = cinza)+
  labs(ggtitle = "Income Groups", x = "Income Groups", y = "Number of Activities")+
  scale_fill_identity(guide = "legend")

plot3<-ggplot(dadosID2, aes(factor(RENDA), SEGMENTOS))+
  geom_boxplot(fill = cinza)+
  labs(ggtitle = "Income Groups", x = "Income Groups", y = "Number of Segments")+
  scale_fill_identity(guide = "legend")

plot4<-ggplot(dadosID2, aes(factor(RENDA), DF_Atv))+
  geom_boxplot(fill = cinza)+
  labs(ggtitle = "Income Groups", x = "Income Groups", y = "Mobility")+
  scale_fill_identity(guide = "legend")

grid.arrange(plot1+temabox, plot2+temabox, plot3+temabox, plot4+temabox, nrow=2, ncol=2)


par(mfrow=c(1,1))

by(dadosID$DF_Atv, dadosID$RENDA, summary)

ggplot(Fractal[Fractal$RENDA == 1 |Fractal$RENDA == 2 | Fractal$RENDA == 3 , ], aes(log(Cell),log(COUNT)))+
  geom_point(aes(color = factor(RENDA)))+
  geom_line(aes(color = factor(RENDA),fill = factor(Name)))





################################################################################
#################################################################### Correlações 
################################################################################


testecor<- dadosID[c(2,15, 16,23)]
testecor<-transform(testecor, RENDA = as.numeric(as.factor(RENDA)))
testecor <- na.omit(testecor)

str(testecor)

cor(testecor, method = "spearman")
cor(testecor, method = "pearson")

ggplot(testecor, aes(Diversidade, DF_Atv))+
  geom_line(aes(color = RENDA))

geom_line()+
  geom_line()

cor.test(testecor$Diversidade, testecor$RENDA, method="pearson")

cor <- cor(dadosID2$DF_Atv, dadosID2$DIVERSIDADE, method = "pearson", use = "complete")

