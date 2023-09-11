library(tidyverse)
library(skimr)
library(corrplot)

df <- read.csv('data/telecom_churn.csv')

# ANÁLISE DESCRITIVA -----------------------------------------------------------

# todas nossas variáveis são numéricas e não temos dados faltantes em nenhuma coluna

skim(df)

# as maiores correlações entre variáveis são DataUsage e DataPlan (0.95)
# e entre MonthlyCharge e DataPlan (0.74) ou MonthlyCharge e DataUsage (0.78)

df |>
  cor() |>
  corrplot(method=c('number'))

# comparando usuários retidos vs. churn, as maiores diferenças aparentam ser entre
# a média de chamadas ao suporte além do uso de dados

medias <- df |>
  group_by(Churn) |>
  summarise_all(.funs=mean)

medias |>
  pivot_longer(cols=-Churn, names_to='Variable', values_to='Value') |>
  mutate(Churn=recode(Churn,"1" = "Sim", "0" = "Não")) |>
  ggplot(aes(x=Churn, y=Value, fill=Churn)) +
  geom_col(show.legend=FALSE) +
  facet_wrap(~Variable, scales='free_y') +
  labs(title="Características vs. Churn") +
  theme_minimal()

# temos uma quantidade relevante de usuários com zero uso de dados, totalizando 54% da base
# apenas 21.6% dos mesmos já deu churn

df |>
  filter(DataUsage==0) |>
  group_by(Churn) |>
  count()

# ao desconsideramos usuários com zero uso de dados, ter um plano de dados não parece
# impactar o churn

medias2 <- df |>
  group_by(DataPlan) |>
  filter(DataUsage>0)
  summarise_all(.funs=mean)

medias2 |>
  pivot_longer(cols=-DataPlan, names_to='Variable', values_to='Value') |>
  mutate(DataPlan=recode(DataPlan,"1" = "Sim", "0" = "Não")) |>
  ggplot(aes(x=DataPlan, y=Value, fill=DataPlan)) +
  geom_col() +
  facet_wrap(~Variable, scales='free_y') +
  theme_minimal()

# a quantidade de usuários que dão churn aumenta até a 100a semana com a conta aberta
# após esse corte o churn volta a cair até estabilizar em ~2 usuários/semana

df |>
  select(AccountWeeks, Churn) |>
  group_by(AccountWeeks) |>
  count() |>
  arrange(AccountWeeks) |>
  ggplot(aes(x=AccountWeeks, y=n)) +
  labs(title='Total de churn vs. semanas com conta ativa', x='Semanas com conta', y='Churn total') +
  geom_point() +
  theme_minimal()

# TESTES DE HIPÓTESE -----------------------------------------------------------

# H0: Usuários utilizando dados sem um plano de dados tem maior probabilidade de churn
# HA: Usuários utilizando dados sem um plano de dados não tem maior probabilidade de churn

# H0: Usuários com conta aberta a mais de 100 semanas tem maior probabilidade de churn
# HA: Usuários com conta aberta a mais de 100 semanas não tem maior probabilidade de churn


# PERFIS DE CLIENTES -----------------------------------------------------------

# para não viesar a segmentação, iremos excluir uma das variáveis com alta correlação
df2 <- df |>
  select(-DataPlan, -Churn)

dendograma <- df2 |>
  dist('euclidean') |>
  hclust(method='ward.D2')

plot(dendograma) # vamos selecionar 4 clusters

cluster = cutree(dendograma, k=4)

df2 [ , 'cluster'] <- cluster

factoextra::fviz_cluster(list(data=df2, cluster=cluster))

# características de cada cluster
mediacluster <- df2 |>
  group_by(cluster) |>
  summarise_all(.funs = mean)

mediacluster |>
  pivot_longer(cols=-cluster, names_to='Variable', values_to='Value') |>
  ggplot(aes(x=cluster, y=Value, fill=cluster)) +
  geom_col(show.legend=FALSE) +
  facet_wrap(~Variable, scales='free_y') +
  labs(title="Características por cluster") +
  theme_minimal()

# MODELO DE PREVISÃO DE CHURN --------------------------------------------------
