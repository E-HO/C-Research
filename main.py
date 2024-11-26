"""
Todo :
	-
"""

import sqlite3
import requests
import datetime
import pandas as pd
from datetime import timedelta

# Parameters
API_FROM_DATE = datetime.datetime(2024, 10, 31) # Year, Month, Date : from when do we need to retrieve data
# hardcoded, but set as first line it's easier to change compared to a line deep into the code, however if you need to be changed regularly => use parameters or environment variables
API_TIMEDELTA = 24 # Numbers of hours, limit the revisions to request into a specific time frame
API_ENDPOINT = "https://www.mediawiki.org/w/api.php"

# Here, suppose the DB is a staging, empty, ready to accept result
engine = sqlite3.connect('C_Research.sqlite')
engine.execute("DROP TABLE IF EXISTS wikimedia_changes")

Session = requests.Session()
def wikimedia_request(rcontinue = {}) -> None:
	"""
	Recursive function to get recent changes made on MediaWiki.
	Doc for specific params : https://www.mediawiki.org/w/api.php?action=help&modules=query%2Brecentchanges

	:param rcontinue: Empty object for first loop, after will use the value as a key to loop into other results
	:return:
	"""

	params = {
		"action": "query",
		"list": "recentchanges",
		"rclimit": "500",  # Max 500
		"rcprop": "title|ids|sizes|timestamp", # What info is provided
		"rctype": "edit|new",
		"rcstart": API_FROM_DATE.strftime("%Y-%m-%dT%H:%M:%SZ"),
		# "rcend": (API_FROM_DATE + timedelta(hours=API_TIMEDELTA)).strftime("%Y-%m-%dT%H:%M:%SZ"), # Empty results when a limit was set !?
		"rcdir": "newer",
		"formatversion": "2",
		"format": "json"
	} | rcontinue # If recursive, will join the 2 objects to make a new request

	request = Session.get(url=API_ENDPOINT, params=params)

	data = request.json()
	changes = data["query"]["recentchanges"]
	# for change in changes:
	# 	print(page)

	# Pandas could be excessive here, but quick step to save data, and let's imagine some manipulations must be done at source ...
	# as like here a tricky example to filter something which should have be filtered at source side
	df = pd.DataFrame(data=changes)
	# print(df.info)
	df = df.query('timestamp.str.contains("'+API_FROM_DATE.strftime("%Y-%m-%d")+'")')
	df.to_sql(con=engine, name='wikimedia_changes', if_exists='append')

	if (data.get("continue")):
		print("Continuation key :", data["continue"]["rccontinue"])
		# return  # Activate to limit to one the execution, for testing purposes
		wikimedia_request({"rccontinue": data["continue"]["rccontinue"]})


wikimedia_request()
engine.close()
