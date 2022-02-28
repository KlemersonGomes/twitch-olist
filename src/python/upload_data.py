import os
import pandas as pd
#pip install sqlalchemy pymysql
import sqlalchemy

'''user = 'twitch' #Login
psw = 'teodoroc' #Senha
host = 'database-1.cjyp1fkhums7.us-east-2.rds.amazonaws.com' #ip/host/dns
port = '3306' #Porta
'''

#str_connection = 'mysql+pymysql:///{user}:{psw}@{host}:{port}'
str_connection = 'sqlite:///{path}'

#Os endereços de nosso projeto e subpastas
BASE_DIR = os.path.dirname(os.path.dirname( os.path.dirname( os.path.abspath(__file__) ) ) )
DATA_DIR = os.path.join( BASE_DIR, 'data' )

'''#Forma 1
files_names = os.listdir( DATA_DIR )
correct_files = []
for i in files_names:
    if i.endswith(".csv"):
        correct_files.append(i)
'''

#Forma 2
files_names = [ i for i in os.listdir( DATA_DIR ) if i.endswith(".csv") ]

# Abrindo conexão com banco
#str_connection = str_connection.format( user = user, psw = psw, host = host, port = port )
str_connection = str_connection.format( path = os.path.join( DATA_DIR, 'olist.db' ) )
connection = sqlalchemy.create_engine( str_connection )

#Para cada arquivo é realizado uma inserção no banco
for i in files_names:
    df_tmp = pd.read_csv( os.path.join( DATA_DIR, i ) )
    table_name = "tb_" + i.strip(".csv").replace("olist_", "").replace("_dataset", "")
    df_tmp.to_sql( table_name, 
                   connection,
                   #schema = 'analytics', 
                   if_exists = 'replace', 
                   index = False )
    #df_tmp.to_sql( table_name, connection)




