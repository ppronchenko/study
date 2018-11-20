
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import datetime
import time
import seaborn as sns
import warnings
warnings.filterwarnings('ignore')
from sklearn.metrics import roc_auc_score, roc_curve
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
import xgboost
import statsmodels.api as sm
import statsmodels.formula.api as smf
from scipy import stats
from sklearn.metrics import brier_score_loss
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import f1_score,confusion_matrix
from sklearn.metrics import accuracy_score


# In[2]:


data = pd.read_csv('data_breast.csv')
data.shape


# https://archive.ics.uci.edu/ml/datasets/Breast+Cancer+Wisconsin+%28Diagnostic%29

# In[3]:


data.info()


# In[4]:


data.head()


# In[5]:


dict_diag = {"B": 0, "M": 1}


# In[6]:


data.diagnosis = data.diagnosis.map(dict_diag)


# In[7]:


data.head()


# In[8]:


l= ['Unnamed: 32','id']
data = data.drop(l,axis = 1)


# In[9]:


y = data.diagnosis
X = data.drop('diagnosis', axis = 1)
cols = X.columns


# In[10]:


ax = sns.countplot(y)


# In[11]:


data.diagnosis.value_counts()


# In[12]:


X.describe()


# In[13]:


X.mode()


# In[14]:


scaler = StandardScaler().fit(X)
X = pd.DataFrame(scaler.transform(X))
X.columns = cols


# In[15]:


data = X 
data = pd.concat([y,data.iloc[:,0:10]],axis=1)
data = pd.melt(data,id_vars="diagnosis",
                    var_name="features",
                    value_name='value')
plt.figure(figsize=(10,10))
sns.boxplot(x="features", y="value", hue="diagnosis", data=data)
plt.xticks(rotation=90)


# In[16]:


data = X
data = pd.concat([y,data.iloc[:,20:31]],axis=1)
data.head()
data = pd.melt(data,id_vars="diagnosis",
                    var_name="features",
                    value_name='value')


# In[17]:


plt.figure(figsize=(10,10))
sns.boxplot(x="features", y="value", hue="diagnosis", data=data)
plt.xticks(rotation=90)


# In[18]:


corr = X.corr()
f,ax = plt.subplots(figsize=(18, 18))
sns.heatmap(corr, annot=True, linewidths=.5, fmt= '.1f',ax=ax)


# In[19]:


# Высокий уровень взаимной корреляции признаков. Необходимо сокращать размерность.


# In[20]:


df = X.loc[:,['radius_worst','perimeter_worst','area_worst']]
sns.pairplot(df)


# In[21]:


stats.ttest_ind(X['radius_worst'], X['perimeter_worst']) 


# In[22]:


stats.ttest_ind(X['radius_worst'], X['area_worst']) 


# In[23]:


stats.ttest_ind(X['perimeter_worst'], X['area_worst']) 


# In[24]:


x_train, x_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=7)


# In[25]:


from sklearn.feature_selection import RFE
# Create the RFE object and rank each pixel
rfclass = RandomForestClassifier()      
rfe = RFE(estimator=rfclass, n_features_to_select=10, step=1)
rfe = rfe.fit(x_train, y_train)
print('Chosen best 10 feature by rfe:',x_train.columns[rfe.support_])


# In[26]:


rfclf = RandomForestClassifier(random_state=42)      
rfclf = rfclf.fit(x_train,y_train)

ac = accuracy_score(y_test, rfclf.predict(x_test))
print('Accuracy is: ',ac)
cm = confusion_matrix(y_test, rfclf.predict(x_test))
cm


# In[27]:


x_train_redused = x_train.loc[:, ['concavity_mean', 'concave points_mean', 'area_se', 'radius_worst',
       'texture_worst', 'perimeter_worst', 'area_worst', 'smoothness_worst',
       'concave points_worst', 'symmetry_worst']]
x_test_reduced = x_test.loc[:, ['concavity_mean', 'concave points_mean', 'area_se', 'radius_worst',
       'texture_worst', 'perimeter_worst', 'area_worst', 'smoothness_worst',
       'concave points_worst', 'symmetry_worst']]
rfclf1 = RandomForestClassifier(random_state=42)      
rfclf1 = rfclf1.fit(x_train_redused,y_train)

ac = accuracy_score(y_test, rfclf1.predict(x_test_reduced))
print('Accuracy is: ',ac)
cm = confusion_matrix(y_test, rfclf1.predict(x_test_reduced))
cm


# In[28]:


#Выбираем стратегию Undersampling|Oversampling 
#https://www.kaggle.com/rafjaa/resampling-strategies-for-imbalanced-datasets


# In[29]:


data2 = pd.concat([y,X],axis=1)


# In[30]:


count_class_0, count_class_1 = data2.diagnosis.value_counts()
df_class_0 = data2[data2['diagnosis'] == 0]
df_class_1 = data2[data2['diagnosis'] == 1]


# In[31]:


df_class_0_under = df_class_0.sample(count_class_1)
df_under = pd.concat([df_class_0_under, df_class_1], axis=0)

print('Random under-sampling:')
print(df_under.diagnosis.value_counts())

df_under.diagnosis.value_counts().plot(kind='bar', title='Count (target)');


# In[32]:


y = df_under.diagnosis
X = df_under.drop('diagnosis', axis = 1)
cols = X.columns


# In[33]:


scaler = StandardScaler().fit(X)
X = pd.DataFrame(scaler.transform(X))
X.columns = cols


# In[34]:


x_train, x_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=7)


# In[35]:


rfclf = RandomForestClassifier(random_state=42)      
rfclf = rfclf.fit(x_train,y_train)

ac = accuracy_score(y_test, rfclf.predict(x_test))
print('Accuracy is: ',ac)
cm = confusion_matrix(y_test, rfclf.predict(x_test))
cm


# In[36]:


#Стратегия undersampling снижает accuracy


# In[37]:


df_class_1_over = df_class_1.sample(count_class_0, replace=True)
df_over = pd.concat([df_class_0, df_class_1_over], axis=0)

print('Random over-sampling:')
print(df_over.diagnosis.value_counts())

df_over.diagnosis.value_counts().plot(kind='bar', title='Count (target)');


# In[38]:


y = df_over.diagnosis
X = df_over.drop('diagnosis', axis = 1)
cols = X.columns


# In[39]:


scaler = StandardScaler().fit(X)
X = pd.DataFrame(scaler.transform(X))
X.columns = cols
X.info()


# In[40]:


x_train, x_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=7)


# In[41]:


rfclf = RandomForestClassifier(random_state=42)      
rfclf = rfclf.fit(x_train,y_train)

ac = accuracy_score(y_test, rfclf.predict(x_test))
print('Accuracy is: ',ac)
cm = confusion_matrix(y_test, rfclf.predict(x_test))
cm


# In[42]:


pca = PCA().fit(X)

cum_evr = np.cumsum(pca.explained_variance_ratio_)
xs = np.arange(cum_evr.size) + 1
plt.plot(xs, cum_evr, linewidth=2)
plt.grid()
plt.xlabel('n_components')
plt.ylabel('explained_variance_ratio_')


# In[43]:


pca = PCA(n_components=20)
X_pca = pca.fit_transform(X)
X_pca = pd.DataFrame(X_pca)
X_pca.info()


# In[44]:


#oversampling повышает accuracy, сделаем PCA на 20 компонент.
#Сделаем кросс-валидацию и выберем модель.


# In[45]:


from sklearn.model_selection import KFold
from sklearn.model_selection import cross_val_score
from sklearn.linear_model import LogisticRegression


# In[46]:


num_folds = 10
seed = 7


# In[47]:


kfold = KFold(n_splits=num_folds, random_state=seed)


# In[48]:


LogReg = LogisticRegression()
results = cross_val_score(LogReg, X_pca, y, cv=kfold)
print("Accuracy: %.3f%% (%.3f%%)" % (results.mean()*100.0, results.std()*100.0
))


# In[49]:


from sklearn.svm import SVC


# In[50]:


svecm = SVC()
results = cross_val_score(svecm, X_pca, y, cv=kfold)
print("Accuracy: %.3f%% (%.3f%%)" % (results.mean()*100.0, results.std()*100.0
))


# In[51]:


from sklearn.tree import DecisionTreeClassifier
destree = DecisionTreeClassifier()
results = cross_val_score(destree, X_pca, y, cv=kfold)
print("Accuracy: %.3f%% (%.3f%%)" % (results.mean()*100.0, results.std()*100.0
))


# In[52]:


import xgboost
# Градиентный бустинг показывает лучший Accuracy 
#без сокращения размерности методом главных компонент


# In[53]:


xgb = xgboost.XGBClassifier(max_depth=5, random_seed = 42, n_jobs=10)
results = cross_val_score(xgb, X, y, cv=kfold)
print("Accuracy: %.3f%% (%.3f%%)" % (results.mean()*100.0, results.std()*100.0
))


# In[54]:


from sklearn.metrics import classification_report


# In[55]:


test_size = 0.2
seed = 7
model = LogReg
X_train, X_test, Y_train, Y_test = train_test_split(X_pca, y, test_size=test_size,
random_state=seed)
model.fit(X_train, Y_train)
predicted = model.predict(X_test)
report = classification_report(Y_test, predicted)
print(report)


# In[56]:


predicted_proba_LogReg = model.predict_proba(X_pca)
for i in predicted_proba_LogReg:
    print("1: {:f}, 0: {:f}".format(i[0], i[1]))


# In[57]:


y_prob = predicted_proba_LogReg[:, 0]
print("Brier_score: %.3f%% " % (brier_score_loss(y, y_prob)))


# In[58]:


test_size = 0.2
seed = 7
model = svecm
X_train, X_test, Y_train, Y_test = train_test_split(X_pca, y, test_size=test_size,
random_state=seed)
model.fit(X_train, Y_train)
predicted = model.predict(X_test)
report = classification_report(Y_test, predicted)
print(report)


# In[59]:


test_size = 0.2
seed = 7
model = destree
X_train, X_test, Y_train, Y_test = train_test_split(X_pca, y, test_size=test_size,
random_state=seed)
model.fit(X_train, Y_train)
predicted = model.predict(X_test)
report = classification_report(Y_test, predicted)
print(report)


# In[60]:


predicted_proba_DesTree = model.predict_proba(X_pca)
for i in predicted_proba_DesTree:
    print("0: {:f}, 1: {:f}".format(i[0], i[1]))


# In[61]:


test_size = 0.2
seed = 7
model = xgb
X_train, X_test, Y_train, Y_test = train_test_split(X, y, test_size=test_size,
random_state=seed)
model.fit(X_train, Y_train)
predicted = model.predict(X_test)
report = classification_report(Y_test, predicted)
print(report)


# In[62]:


predicted_proba_xgb = model.predict_proba(X)
for i in predicted_proba_xgb:
    print("0: {:f}, 1: {:f}".format(i[0], i[1]))


# In[63]:


y_prob = predicted_proba_xgb[:, 0]


# In[64]:


print("Brier_score: %.3f%% " % (brier_score_loss(y, y_prob))) 

