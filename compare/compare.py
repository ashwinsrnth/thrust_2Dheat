import subprocess

# grid sizes
sizes = [50, 100, 150, 200, 250, 500, 750, 1000, 1250, 1500, 2000]

# run times
cam_times = []
thrust_times = []


for size in sizes:
    thrust = subprocess.Popen(['../bin/thrust_2Dheat.bin', str(size), str(size)], stdout=subprocess.PIPE)
    thrust_out = thrust.communicate()[0]
    thrust_times.append(thrust_out.split()[-1])
    thrust.wait()

for size in sizes:
    cam = subprocess.Popen(['../bin/cam_2Dheat.bin', str(size), str(size)], stdout=subprocess.PIPE)
    cam_out = cam.communicate()[0]
    cam_times.append(cam_out.split()[-1])
    cam.wait()


with open('compare.txt', 'w') as f:
    for i in range(len(cam_times)):
        f.writelines([sizes[i], thrust_times[i], cam_times[i]])



