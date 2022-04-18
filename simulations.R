# install.packages('parameters')
library(lavaan)
library(parameters)

set.seed(1)
sims = 300
N = 100000

x <- c("p_val", "se", "coef", "aic", "bic", "df", "cfi", "rmsea", "chisq", "trucoef")

df1_full = data.frame(matrix(ncol = 10, nrow = 0))
colnames(df1_full) <- x
df1_red = data.frame(matrix(ncol = 10, nrow = 0))
colnames(df1_red) <- x
df2_full = data.frame(matrix(ncol = 10, nrow = 0))
colnames(df2_full) <- x
df2_redi = data.frame(matrix(ncol = 10, nrow = 0))
colnames(df2_redi) <- x
df2_redii = data.frame(matrix(ncol = 10, nrow = 0))
colnames(df2_redii) <- x
df3_full = data.frame(matrix(ncol = 10, nrow = 0))
colnames(df3_full) <- x
df3_redi = data.frame(matrix(ncol = 10, nrow = 0))
colnames(df3_redi) <- x
df3_redii = data.frame(matrix(ncol = 10, nrow = 0))
colnames(df3_redii) <- x
df4_full = data.frame(matrix(ncol = 10, nrow = 0))
colnames(df4_full) <- x
df4_red = data.frame(matrix(ncol = 10, nrow = 0))
colnames(df4_red) <- x
df5_full = data.frame(matrix(ncol = 10, nrow = 0))
colnames(df5_full) <- x
df5_red = data.frame(matrix(ncol = 10, nrow = 0))
colnames(df5_red) <- x


full_mod1 =  'X ~ A + C
              M ~ a*X
              Y ~ C + b*M
              ab := a*b # target '
rem_mod1 =  'Y ~ ab*X + C # target'



full_mod2 =  'X ~ A + K
              M ~ b*X
              P ~ K
              R ~ P
              Y ~ R + P + a*M
              N ~ M
              H ~ Y
              ab := a*b  # target'
rem_mod2i =  'Y ~ ab*X + K # target'
rem_mod2ii =  'Y ~ a*M + K
              M ~ b*X
              ab := a*b  # target'


full_mod3 =  'A ~ S + Q + C
              C ~ S
              L ~ S + C  # no U (unobserved)
              H ~ a*C
              M ~ b*H + c*C + S + Q
              ab := a*b
              abc := (a*b) + c  # target'
rem_mod3i =  'M ~ abc*C + S # target '
rem_mod3ii =  'M ~ S + c*C + b*H
               H ~ a*C
               ab := a*b
               abc := (a*b) + c  # target'


full_mod4 =  'R ~ a*S + C
              C ~ U   # assumes U is inferred by measurement model
              S ~ U  # assumes U is inferred by measurement model'
rem_mod4 = 'R ~ a*S + C # target'


full_mod5 =  'B3 ~ a3b3*A3 + B2 + C + a2b3*A2
              A3 ~ a2a3*A2 + C
              B2 ~ B1 + C
              A2 ~ a1a2*A1 + C
              A1 ~ C
              B1 ~ C
              t := a1a2 * ((a2a3 * a3b3) + a2b3)  # target'
rem_mod5 =  'B3 ~ a3b3*A3 + B2 + C + a2b3*A2
             A3 ~ a2a3*A2 + C
             B2 ~ B1 + C
             A2 ~ a1a2*A1 + C
              t := a1a2 * ((a2a3 * a3b3) + a2b3)  # target'

ex_1 <- function(N){
  uA = 1.0*rnorm(N)
  uX = 1.0*rnorm(N)
  uC = 1.0*rnorm(N)
  uM = 1.0*rnorm(N)
  uY = 1.0*rnorm(N)

  C = uC
  A = uA
  X = uX + 0.8 * C + 0.8 * A
  M = uM + 0.8 * X
  Y = uY + 0.8 * M + 0.8 * C 

  df = data.frame(cbind(C, A, X, M, Y))
  return (df) }

ex_2 <- function(N){
  uA = 1.0*rnorm(N)
  uK = 1.0*rnorm(N)
  uP = 1.0*rnorm(N)
  uX = 1.0*rnorm(N)
  uR = 1.0*rnorm(N)
  uY = 1.0*rnorm(N)
  uM = 1.0*rnorm(N)
  uH = 1.0*rnorm(N)
  uN = 1.0*rnorm(N)

  A = uA
  K = uK
  X = uX +0.8 * A + 0.8 * K
  P = uP + 0.8 * K
  M = uM + 0.8 * X
  R = uR + 0.8 * P
  N = uN + 0.8 * M
  Y = uY + 0.8 * P + 0.8 * R + 0.8 * M
  H = uH + 0.8 * Y
  
  df = data.frame(cbind(A, K, X, P, M, R, N, Y, H))
  return (df) }

ex_3 <- function(N){
  uS = 1.0*rnorm(N)
  uC = 1.0*rnorm(N)
  uA = 1.0*rnorm(N)
  uL = 1.0*rnorm(N)
  uH = 1.0*rnorm(N)
  uM = 1.0*rnorm(N)
  uQ = 1.0*rnorm(N)
  uU = 1.0*rnorm(N)
  
  S = uS
  Q = uQ
  U = uU
  C = uC + 0.8 * S
  A = uA + 0.8 * S + 0.8 * Q + 0.8 * C
  L = uL + 0.8 * S + 0.8 * C + 0.8 * U
  H = uH + 0.8 * C
  M = uM + 0.8 * H + 0.8 * C + 0.8 * S + 0.8 * Q + 0.8 * U

  
  df = data.frame(cbind(S, Q, U, A, C, L, H, M))
  return (df) }

ex_4 <- function(N){
  uU = 1.0*rnorm(N)
  uS = 1.0*rnorm(N)
  uC = 1.0*rnorm(N)
  uR = 1.0*rnorm(N)

  
  U = uU
  S = uS + 0.8 * U
  C = uC + 0.8 * U
  R = uR + 0.8 * C + 0.8 * S

  df = data.frame(cbind(U,S,C,R))
  return (df) }

ex_5 <- function(N){
  uA1 = 1.0*rnorm(N)
  uA2 = 1.0*rnorm(N)
  uA3 = 1.0*rnorm(N)
  uB1 = 1.0*rnorm(N)
  uB2 = 1.0*rnorm(N)
  uB3 = 1.0*rnorm(N)
  uC = 1.0*rnorm(N)
  
  C = uC
  A1 = uA1 + 0.8 * C
  B1 = uB1 + 0.8 * C
  A2 = uA2 + 0.8 * A1 + 0.8 * C
  B2 = uB2 + 0.8 * B1 + 0.8 * C
  A3 = uA3 + 0.8 * A2 + 0.8 * C
  B3 = uB3 + 0.8 * C + 0.8 * A2 + 0.8 * A3 + 0.8 * B2
  
  df = data.frame(cbind(A1, A2, A3, B1, B2, B3, C))
  return (df) }



for (N in c(10,20,40,80,160,320, 640, 1280, 2560, 5120, 10240)){
  print(paste("N:", as.character(N)))
for (i in 1:sims) {
  print(i)
df_ex1 = ex_1(N)
df_ex2 = ex_2(N)
df_ex3 = ex_3(N)
df_ex4 = ex_4(N)
df_ex5 = ex_5(N)

full_sem_mod1 = sem(full_mod1, data=df_ex1)
params=model_parameters(full_sem_mod1)
p_val = params[7,9]
se = params[7,5]
coef = params[7,4]
aic = AIC(full_sem_mod1)
bic = BIC(full_sem_mod1)
fms = fitMeasures(full_sem_mod1, c("df", "cfi","rmsea","chisq"))
fms = data.frame(fms)
fms = fms$fms
trucoef = 0.64
df1_full[nrow(df1_full) + 1,] = c(p_val, se, coef, aic, bic, fms, trucoef)


rem_sem_mod1 = sem(rem_mod1, data=df_ex1)
params=model_parameters(rem_sem_mod1)
p_val = params[1,9]
se = params[1,5]
coef = params[1,4]
aic = AIC(full_sem_mod1)
bic = BIC(full_sem_mod1)
fms = fitMeasures(rem_sem_mod1, c("df", "cfi","rmsea","chisq"))
fms = data.frame(fms)
fms = fms$fms
trucoef = 0.64
df1_red[nrow(df1_red) + 1,] = c(p_val, se, coef, aic, bic, fms, trucoef)

full_sem_mod2 = sem(full_mod2, data=df_ex2)
params=model_parameters(full_sem_mod2)
p_val = params[13,9]
se = params[13,5]
coef = params[13,4]
aic = AIC(full_sem_mod1)
bic = BIC(full_sem_mod1)
fms = fitMeasures(full_sem_mod2, c("df", "cfi","rmsea","chisq"))
fms = data.frame(fms)
fms = fms$fms
trucoef = 0.64
df2_full[nrow(df2_full) + 1,] = c(p_val, se, coef, aic, bic, fms, trucoef)


rem_sem_mod2i = sem(rem_mod2i, data=df_ex2)
params=model_parameters(rem_sem_mod2i)
p_val = params[1,9]
se = params[1,5]
coef = params[1,4]
aic = AIC(full_sem_mod1)
bic = BIC(full_sem_mod1)
fms = fitMeasures(rem_sem_mod2i, c("df", "cfi","rmsea","chisq"))
fms = data.frame(fms)
fms = fms$fms
trucoef = 0.64
df2_redi[nrow(df2_redi) + 1,] = c(p_val, se, coef, aic, bic, fms, trucoef)


rem_sem_mod2ii = sem(rem_mod2ii, data=df_ex2)
params=model_parameters(rem_sem_mod2ii)
p_val = params[5,9]
se = params[5,5]
coef = params[5,4]
aic = AIC(full_sem_mod1)
bic = BIC(full_sem_mod1)
fms = fitMeasures(rem_sem_mod2ii, c("df", "cfi","rmsea","chisq"))
fms = data.frame(fms)
fms = fms$fms
trucoef = 0.64
df2_redii[nrow(df2_redii) + 1,] = c(p_val, se, coef, aic, bic, fms, trucoef)


full_sem_mod3 = sem(full_mod3, data=df_ex3)
params=model_parameters(full_sem_mod3)
p_val = params[17,9]
se = params[17,5]
coef = params[17,4]
aic = AIC(full_sem_mod1)
bic = BIC(full_sem_mod1)
fms = fitMeasures(full_sem_mod3, c("df", "cfi","rmsea","chisq"))
fms = data.frame(fms)
fms = fms$fms
trucoef = 1.44
df3_full[nrow(df3_full) + 1,] = c(p_val, se, coef, aic, bic, fms, trucoef)

rem_sem_mod3i = sem(rem_mod3i, data=df_ex3)
params=model_parameters(rem_sem_mod3i)
p_val = params[1,9]
se = params[1,5]
coef = params[1,4]
aic = AIC(full_sem_mod1)
bic = BIC(full_sem_mod1)
fms = fitMeasures(rem_sem_mod3i, c("df", "cfi","rmsea","chisq"))
fms = data.frame(fms)
fms = fms$fms
trucoef = 1.44
df3_redi[nrow(df3_redi) + 1,] = c(p_val, se, coef, aic, bic, fms, trucoef)

rem_sem_mod3ii = sem(rem_mod3ii, data=df_ex3)
params=model_parameters(rem_sem_mod3ii)
p_val = params[7,9]
se = params[7,5]
coef = params[7,4]
aic = AIC(full_sem_mod1)
bic = BIC(full_sem_mod1)
fms = fitMeasures(rem_sem_mod3ii, c("df", "cfi","rmsea","chisq"))
fms = data.frame(fms)
fms = fms$fms
trucoef = 1.44
df3_redii[nrow(df3_redii) + 1,] = c(p_val, se, coef, aic, bic, fms, trucoef)

full_sem_mod4 = sem(full_mod4, data=df_ex4)
params=model_parameters(full_sem_mod4)
p_val = params[1,9]
se = params[1,5]
coef = params[1,4]
aic = AIC(full_sem_mod1)
bic = BIC(full_sem_mod1)
fms = fitMeasures(full_sem_mod4, c("df", "cfi","rmsea","chisq"))
fms = data.frame(fms)
fms = fms$fms
trucoef = 0.8
df4_full[nrow(df4_full) + 1,] = c(p_val, se, coef, aic, bic, fms, trucoef)

rem_sem_mod4 = sem(rem_mod4, data=df_ex4)
params=model_parameters(rem_sem_mod4)
p_val = params[1,9]
se = params[1,5]
coef = params[1,4]
aic = AIC(full_sem_mod1)
bic = BIC(full_sem_mod1)
fms = fitMeasures(rem_sem_mod4, c("df", "cfi","rmsea","chisq"))
fms = data.frame(fms)
fms = fms$fms
trucoef = 0.8
df4_red[nrow(df4_red) + 1,] = c(p_val, se, coef, aic, bic, fms, trucoef)

full_sem_mod5 = sem(full_mod5, data=df_ex5)
params=model_parameters(full_sem_mod5)
p_val = params[13,9]
se = params[13,5]
coef = params[13,4]
aic = AIC(full_sem_mod1)
bic = BIC(full_sem_mod1)
fms = fitMeasures(full_sem_mod5, c("df", "cfi","rmsea","chisq"))
fms = data.frame(fms)
fms = fms$fms
trucoef = 1.15
df5_full[nrow(df5_full) + 1,] = c(p_val, se, coef, aic, bic, fms, trucoef)

rem_sem_mod5 = sem(rem_mod5, data=df_ex5)
params=model_parameters(rem_sem_mod5)
p_val = params[14,9]
se = params[14,5]
coef = params[14,4]
aic = AIC(full_sem_mod1)
bic = BIC(full_sem_mod1)
fms = fitMeasures(rem_sem_mod5, c("df", "cfi","rmsea","chisq"))
fms = data.frame(fms)
fms = fms$fms
trucoef = 1.15
df5_red[nrow(df5_red) + 1,] = c(p_val, se, coef, aic, bic, fms, trucoef)
}


Nstr = as.character(N)
fn = "_mod1_full.csv"
write.csv(df1_full, paste(Nstr, fn), row.names=FALSE)

fn = "_mod1_red.csv"
write.csv(df1_red, paste(Nstr, fn), row.names=FALSE)

fn = "_mod2_full.csv"
write.csv(df2_full, paste(Nstr, fn), row.names=FALSE)

fn = "_mod2_redi.csv"
write.csv(df2_redi, paste(Nstr, fn), row.names=FALSE)

fn = "_mod2_redii.csv"
write.csv(df2_redii, paste(Nstr, fn), row.names=FALSE)

fn = "_mod3_full.csv"
write.csv(df3_full, paste(Nstr, fn), row.names=FALSE)

fn = "_mod3_redi.csv"
write.csv(df3_redi, paste(Nstr, fn), row.names=FALSE)

fn = "_mod3_redii.csv"
write.csv(df3_redii, paste(Nstr, fn), row.names=FALSE)

fn = "_mod4_full.csv"
write.csv(df4_full, paste(Nstr, fn), row.names=FALSE)

fn = "_mod4_red.csv"
write.csv(df4_red, paste(Nstr, fn), row.names=FALSE)

fn = "_mod5_full.csv"
write.csv(df5_full, paste(Nstr, fn), row.names=FALSE)

fn = "_mod5_red.csv"
write.csv(df5_red, paste(Nstr, fn), row.names=FALSE)
}
