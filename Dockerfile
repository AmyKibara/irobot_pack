FROM ros:jazzy-ros-base

# Install dependencies, utilities, and required RMW implementations
RUN apt-get update && apt-get install -y \
    ros-jazzy-rmw-fastrtps-cpp \
    ros-jazzy-rmw-cyclonedds-cpp \
    ros-jazzy-rmw-zenoh-cpp \
    python3-pip \
    python3-matplotlib \
    python3-pandas \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set up ROS2 workspace and clone the source code natively
WORKDIR /benchmark_ws/src
RUN git clone https://github.com/irobot-ros/ros2-performance.git

WORKDIR /benchmark_ws

# Limit executors and parallel jobs to prevent OOM on 4GB RAM instances
RUN . /opt/ros/jazzy/setup.sh && \
    colcon build \
    --executor sequential \
    --parallel-workers 1 \
    --cmake-args -DCMAKE_BUILD_TYPE=Release

# Automatically source setup scripts upon container instantiation
RUN echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc \
    && echo "source /benchmark_ws/install/setup.bash" >> ~/.bashrc

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
