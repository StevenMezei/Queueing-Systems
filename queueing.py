import ciw
import pandas as pd
import math
from datetime import datetime

queue_data_auc_wkday = {
    'Hour': ['00:00:00', '04:00:00', '08:00:00', '12:00:00', '16:00:00', '20:00:00'],
    'Arrival_rate': [0.094, 0, 2.284, 1.643, 1.666, 0.962],
    'Service_rate': [0.282, 0, 1.205, 1.836, 1.921, 1.203],
    '# of Servers': [1, 0, 2, 1, 1, 1]
}

queue_data_auc_wkend = {
    'Hour': ['00:00:00', '04:00:00', '08:00:00', '12:00:00', '16:00:00', '20:00:00'],
    'Arrival_rate': [0, 0.783, 2.045, 1.707, 1.784, 0.935],
    'Service_rate': [0, 0.490, 1.102, 1.920, 2.029, 1.146],
    '# of Servers': [0, 2, 2, 1, 1, 1]
}

queue_data_saf_wkday = {
    'Hour': ['00:00:00', '04:00:00', '08:00:00', '12:00:00', '16:00:00', '20:00:00'],
    'Arrival_rate': [0, 0, 0.347, 0.233, 0.067, 0.154],
    'Service_rate': [0, 0, 0.229, 0.384, 0.422, 0.473],
    '# of Servers': [0, 0, 2, 1, 1, 1]
}

queue_data_saf_wkend = {
    'Hour': ['00:00:00', '04:00:00', '08:00:00', '12:00:00', '16:00:00', '20:00:00'],
    'Arrival_rate': [0.079, 0, 0.292, 0.454, 0.271, 0.244],
    'Service_rate': [0.115, 0, 0.445, 0.282, 0.390, 0.195],
    '# of Servers': [2, 0, 1, 2, 1, 2]
}

class Model:

    def __init__(self, dt, air):

        weekend = 0
        df_q = 0
        if dt.weekday() >= 5:
            weekend = 1

        hour = math.floor(dt.hour / 4)
        if weekend == 1 and air == "AUC":
            df_q = pd.DataFrame(queue_data_auc_wkend)

        if weekend == 0 and air == "AUC":
            df_q = pd.DataFrame(queue_data_auc_wkday)

        if weekend == 1 and air == "SAF":
            df_q = pd.DataFrame(queue_data_saf_wkend)

        if weekend == 0 and air == "SAF":
            df_q = pd.DataFrame(queue_data_saf_wkday)

        arrival_rate = df_q.iloc[hour]['Arrival_rate']
        departure_rate = df_q.iloc[hour]['Service_rate']
        servers = int(df_q.iloc[hour]['# of Servers'])

        self.hour = hour

        if servers == 0:
            self.arrival_rate = 0
            self.L = 0
            self.waiting_time = 0
            self.servers = 0

        else:
            self.arrival_rate = arrival_rate
            self.departure_rate = departure_rate
            self.servers = servers

            N = ciw.create_network(
                arrival_distributions=[ciw.dists.Exponential(rate=arrival_rate)],
                service_distributions=[ciw.dists.Exponential(rate=departure_rate)],
                number_of_servers=[servers]
            )

            Q = ciw.Simulation(N)

            Q.simulate_until_max_time(240.0)

            records = Q.get_all_records()

            # Calculate the average wait time using pandas (optional, but highly recommended)
            df = pd.DataFrame(records)

            self.waiting_time = round(df['waiting_time'].mean(), 2)
            L = self.waiting_time * self.arrival_rate
            self.L = math.ceil(L)
            self.max_wait = round(df['waiting_time'].max(), 2)
            self.Q = df

            df.to_csv("output.csv", index=False)

    def find_num_in_queue(self, dt):
        hour = math.floor(dt.hour / 4)
        minute = dt.minute

        time = hour * 60 + minute

        min_in_queue = self.Q[ (self.Q["arrival_date"] < time) & (self.Q["service_start_date"] > time)]

        return len(min_in_queue)

    def estimate_waiting_time(self, dt):
        wait_time = self.find_num_in_queue(dt) * self.departure_rate/self.servers

        return wait_time
