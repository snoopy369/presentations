#!/usr/bin/env python
# coding: utf-8

# In[1]:


import urllib
from urllib.request import urlopen
from bs4 import BeautifulSoup


# In[136]:


def ops_tot(team_str):
    response = urlopen('https://www.baseball-reference.com' + team_str)
    html_doc = response.read()
    soup = BeautifulSoup(html_doc, 'html.parser')
  
    table = soup.find('table',id='team_batting')
    if table != None:       
        for tfoot in table.tfoot:
            td = tfoot.find_all('td')
            for t in td:
                if t['data-stat'] == 'onbase_plus_slugging_plus' and t.text != '':
                    return(t.text)


# In[137]:


ops = ops_tot('/teams/ATL/2021-batting.shtml')
print(ops)


# In[145]:


def ws_winners():
    response = urlopen('https://www.baseball-reference.com/postseason/world-series.shtml')
    html_doc = response.read()
    soup = BeautifulSoup(html_doc, 'html.parser')
    
    
    stats = []                                       #initialize the list to store our stats in
    
    table = soup.find('table',id='world_series_winners_al_nl')
    if table != None:
        for row in table.find_all('tr'):
            ws_stats = {}                            #initialize our dictionary
            if row.contents[0].name == 'th':         #Look for th at the start - identifies relevant rows here
                year = row.contents[0].text          #grab the year
                strong_cells = row.find_all('strong')#look for cells with <strong> tag - W.S. winner is bolded! 
                for cell in strong_cells:                    
                    try:                             #need try-except because of bolded Wins which have nothing to find
                        link = cell.find('a')['href']#find the value of the href attribute in the anchor tag <a href=...>
                        ws_stats['team'] = cell.text #the team name
                        ws_stats['ops+'] = int(ops_tot(link))  #call the earlier function to read the OPS+ from a team page
                        ws_stats['year'] = year       #save the year
                        stats.append(ws_stats)        #append to the main list
                        print(ws_stats)              
                    except(TypeError):
                        pass
                    
    return(stats)                                     #return the value


# In[146]:


final_stats = ws_winners()


# In[147]:


minOPS = min(final_stats,key=lambda x:x['ops+'])
print(minOPS)


# In[ ]:




