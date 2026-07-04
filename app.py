import streamlit as st
import numpy as np
import pandas as pd
import plotly.graph_objects as go
from datetime import datetime
from streamlit_autorefresh import st_autorefresh
import queueing

# =========================
# CONFIG
# =========================
st.set_page_config(page_title="Airport Dashboard", layout="wide")

# Auto refresh (keeps system live, NOT clock)
st_autorefresh(interval=30000, key="live_refresh")

# =========================
# CSS STYLING
# =========================
st.markdown("""
<style>

.stApp {
    background-color: #F8FAFC;
    color: #0F172A;
}

/* TITLE */
.title {
    font-size: 26px;
    font-weight: 700;
    color: #0F172A;
    margin-bottom: 10px;
}

/* HEADER */
.header-box {
    background: white;
    padding: 15px;
    border-radius: 12px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.06);
    color: #0F172A;
}

/* WEATHER */
.weather-box {
    background: linear-gradient(135deg, #60A5FA, #3B82F6);
    color: white;
    padding: 12px;
    border-radius: 12px;
    font-size: 14px;
}

/* KPI */
.kpi {
    background: white;
    padding: 15px;
    border-radius: 12px;
    text-align: center;
    box-shadow: 0 2px 10px rgba(0,0,0,0.06);
}

.kpi-value {
    font-size: 24px;
    font-weight: bold;
    color: #0F172A;
}

.kpi-label {
    font-size: 13px;
    color: #64748B;
}

/* SIDEBAR DARK MODE */
section[data-testid="stSidebar"] {
    background-color: #0F172A !important;
}

section[data-testid="stSidebar"] * {
    color: #F8FAFC !important;
}

section[data-testid="stSidebar"] label {
    color: #E2E8F0 !important;
}

section[data-testid="stSidebar"] .stAlert {
    background-color: #1E293B !important;
    color: #F8FAFC !important;
}

</style>
""", unsafe_allow_html=True)

# =========================
# TITLE
# =========================
st.markdown("<div class='title'>✈ Airport Operations Dashboard </div>", unsafe_allow_html=True)

# =========================
# TOP HEADER (LAST UPDATED TIME)
# =========================
last_updated = datetime.now().strftime("%H:%M:%S")

col1, col2 = st.columns([3, 1])

with col1:
    st.markdown(f"""
    <div class="header-box">
        <b>Airport:</b> AUC<br>
        <b>Status:</b> 🟢 Live System<br>
        <b>Last Updated:</b> {last_updated} <b><b><b>or Updated every 30 Seconds 
    </div>
    """, unsafe_allow_html=True)

with col2:
    temp = np.random.randint(-2, 30)
    cond = np.random.choice(["Sunny", "Cloudy", "Rainy", "Windy"])

    st.markdown(f"""
    <div class="weather-box">
        🌤 Weather<br><br>
        Temp: {temp}°C<br>
        {cond}<br>
        Impact: {"Low Risk" if temp > 10 else "Delay Risk"}
    </div>
    """, unsafe_allow_html=True)

st.markdown("---")

# =========================
# SIDEBAR
# =========================
st.sidebar.title("🛫 AIRPORT CONTROL PANEL")

airport = st.sidebar.radio("Select Airport", ["AUC", "SAF"])
mode = st.sidebar.toggle("Simulation Mode", True)

st.sidebar.markdown("---")
st.sidebar.info("System Live 🟢")

# =========================
# SYSTEM OVERVIEW (FIXED UI)
# =========================
st.markdown("### System Overview")

col1, col2 = st.columns(2)

with col1:
    st.markdown("""
    <div style="
        background-color: skyblue;
        padding: 15px;
        border-radius: 12px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.06);
        color: #0F172A;
        margin-bottom: 10px;
    ">
        🧍 Passenger Flow: <b style="color:#1E3A8A;">Stable</b>
    </div>
    """, unsafe_allow_html=True)

with col2:
    st.markdown("""
    <div style="
        background-color: skyblue;
        padding: 15px;
        border-radius: 12px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.06);
        color: #0F172A;
    ">
        🚦 Security Checkpoints: <b style="color:#1E3A8A;">3 Active</b>
    </div>
    """, unsafe_allow_html=True)

# =========================
# LIVE DATA
# =========================
model = queueing.Model(datetime.now(), airport)
wait_time = model.waiting_time
queue = model.L
arrivals = model.arrival_rate
server = model.servers

# =========================
# KPI ROW
# =========================
c1, c2, c3, c4 = st.columns(4)


def kpi(label, value):
    st.markdown(f"""
    <div class="kpi">
        <div class="kpi-label">{label}</div>
        <div class="kpi-value">{value}</div>
    </div>
    """, unsafe_allow_html=True)


with c1:
    kpi("WAIT TIME (CORE)", f"{wait_time} min")

with c2:
    kpi("Queue Length", queue)

with c3:
    kpi("Passengers/hr", arrivals)

with c4:
    kpi("Number of Servers", server)

st.markdown("---")

# =========================
# GAUGE CHART
# =========================
fig = go.Figure(go.Indicator(
    mode="gauge+number",
    value=wait_time,
    title={'text': "Live Wait Time"},
    gauge={
        'axis': {'range': [0, 60]},
        'bar': {'color': "#3B82F6"},
        'steps': [
            {'range': [0, 15], 'color': "#DCFCE7"},
            {'range': [15, 30], 'color': "#FEF9C3"},
            {'range': [30, 60], 'color': "#FECACA"}
        ],
    }
))

fig.update_layout(
    paper_bgcolor="white",
    plot_bgcolor="white",
    font=dict(color="#0F172A", size=14)
)

st.plotly_chart(fig, use_container_width=True)

# =========================
# STATUS (FIXED VISIBILITY)
# =========================

if wait_time < 15:
    status_text = "🟢 Normal Operations"
    bg = "#DCFCE7"
    color = "#14532D"

elif wait_time < 30:
    status_text = "🟡 Moderate Traffic"
    bg = "#FEF9C3"
    color = "#713F12"

else:
    status_text = "🔴 High Congestion"
    bg = "#FECACA"
    color = "#7F1D1D"

st.markdown(f"""
<div style="
    background-color: {bg};
    color: {color};
    padding: 14px;
    border-radius: 10px;
    font-weight: 700;
    font-size: 16px;
">
    {status_text}
</div>
""", unsafe_allow_html=True)

st.markdown("---")

