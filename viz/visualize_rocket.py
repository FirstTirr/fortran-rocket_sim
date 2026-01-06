import matplotlib.pyplot as plt
import pandas as pd
import os

# Define the path to the data file
data_file = 'viz/flight_data.csv'

# Check if file exists
if not os.path.exists(data_file):
    print(f"Error: {data_file} not found. Please run the simulation first.")
    exit()

# Read the data
# The header in the file has 5 columns but the data only has 4.
# We will manually define the column names to avoid issues.
column_names = ['Time', 'Altitude', 'Velocity', 'Mass']
try:
    # Skip the header row (row 0) and read the first 4 columns
    df = pd.read_csv(data_file, skiprows=1, names=column_names, usecols=[0, 1, 2, 3])
except Exception as e:
    print(f"Error reading CSV file: {e}")
    # Fallback for simple parsing if pandas fails or isn't installed (though unlikely in this env)
    import csv
    data = []
    with open(data_file, 'r') as f:
        reader = csv.reader(f)
        next(reader) # Skip header
        for row in reader:
            if len(row) >= 4:
                data.append([float(x) for x in row[:4]])
    df = pd.DataFrame(data, columns=column_names)

# Create a figure with subplots
fig, axs = plt.subplots(3, 1, figsize=(10, 12), sharex=True)

# Plot Altitude
axs[0].plot(df['Time'], df['Altitude'], color='blue', linewidth=2)
axs[0].set_ylabel('Altitude (km)')
axs[0].set_title('Rocket Flight Telemetry')
axs[0].grid(True)

# Plot Velocity
axs[1].plot(df['Time'], df['Velocity'], color='orange', linewidth=2)
axs[1].set_ylabel('Velocity (m/s)')
axs[1].grid(True)

# Plot Mass
axs[2].plot(df['Time'], df['Mass'], color='green', linewidth=2)
axs[2].set_ylabel('Mass (kg)')
axs[2].set_xlabel('Time (s)')
axs[2].grid(True)

# Adjust layout
plt.tight_layout()

# Save the plot
script_dir = os.path.dirname(os.path.abspath(__file__))
output_file = os.path.join(script_dir, 'rocket_telemetry.png')
plt.savefig(output_file)
print(f"Visualization saved to {output_file}")

# Remove accidental duplicate in current dir if we are not running from viz folder
if os.getcwd() != script_dir and os.path.exists("rocket_telemetry.png"):
    os.remove("rocket_telemetry.png")
    print("Removed duplicate rocket_telemetry.png from current directory")

# Show the plot
plt.show()
