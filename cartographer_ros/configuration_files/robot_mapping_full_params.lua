-- Copyright 2016 The Cartographer Authors
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

include "map_builder.lua"
include "trajectory_builder.lua"

options = {
  map_builder = MAP_BUILDER,
  trajectory_builder = TRAJECTORY_BUILDER,
  map_frame = "map",
  tracking_frame = "base_link",
  published_frame = "base_link",
  odom_frame = "odom",
  provide_odom_frame = false,
  publish_frame_projected_to_2d = false,
  use_pose_extrapolator = true,
  use_odometry = true,
  use_nav_sat = false,
  use_landmarks = false,
  num_laser_scans = 1,
  num_multi_echo_laser_scans = 0,
  num_subdivisions_per_laser_scan = 1,
  num_point_clouds = 0,
  lookup_transform_timeout_sec = 0.2,
  submap_publish_period_sec = 0.3,
  pose_publish_period_sec = 5e-3,
  trajectory_publish_period_sec = 30e-3,
  rangefinder_sampling_ratio = 1.,
  odometry_sampling_ratio = 1.,
  fixed_frame_pose_sampling_ratio = 1.,
  imu_sampling_ratio = 1.,
  landmarks_sampling_ratio = 1.,
}

MAP_BUILDER.use_trajectory_builder_2d = true

-- Input
TRAJECTORY_BUILDER_2D.min_range = 0.1
TRAJECTORY_BUILDER_2D.max_range = 25.
TRAJECTORY_BUILDER_2D.missing_data_ray_length = 1.                                          -- 超过max_range将用该值代替
TRAJECTORY_BUILDER_2D.num_accumulated_range_data = 1                                        -- 多个数据组合为一个数据
TRAJECTORY_BUILDER_2D.voxel_filter_size = 0.01                                              -- voxel边长
TRAJECTORY_BUILDER_2D.adaptive_voxel_filter.max_length = 200
TRAJECTORY_BUILDER_2D.adaptive_voxel_filter.min_num_points = 50
TRAJECTORY_BUILDER_2D.use_imu_data = false
TRAJECTORY_BUILDER_2D.imu_gravity_time_constant = 5                                         --IMU重力初始化时间 s


--Local SLAM
TRAJECTORY_BUILDER_2D.ceres_scan_matcher.occupied_space_weight = 1                          -- 匹配权重
TRAJECTORY_BUILDER_2D.ceres_scan_matcher.translation_weight = 10                            -- 初值平移权重
TRAJECTORY_BUILDER_2D.ceres_scan_matcher.rotation_weight = 0.1                               -- 初值旋转权重
TRAJECTORY_BUILDER_2D.ceres_scan_matcher.ceres_solver_options.use_nonmonotonic_steps = false
TRAJECTORY_BUILDER_2D.ceres_scan_matcher.ceres_solver_options.max_num_iterations = 20
TRAJECTORY_BUILDER_2D.ceres_scan_matcher.ceres_solver_options.num_threads = 12

TRAJECTORY_BUILDER_2D.use_online_correlative_scan_matching = true
TRAJECTORY_BUILDER_2D.real_time_correlative_scan_matcher.linear_search_window = 0.15
TRAJECTORY_BUILDER_2D.real_time_correlative_scan_matcher.angular_search_window = math.rad(20.)
TRAJECTORY_BUILDER_2D.real_time_correlative_scan_matcher.translation_delta_cost_weight = 1e-1
TRAJECTORY_BUILDER_2D.real_time_correlative_scan_matcher.rotation_delta_cost_weight = 1e-1

TRAJECTORY_BUILDER_2D.motion_filter.max_time_seconds = 5.0
TRAJECTORY_BUILDER_2D.motion_filter.max_distance_meters = 0.2
TRAJECTORY_BUILDER_2D.motion_filter.max_angle_radians = math.rad(0.1)

--Submap
TRAJECTORY_BUILDER_2D.submaps.num_range_data = 300
TRAJECTORY_BUILDER_2D.submaps.grid_options_2d.grid_type = "PROBABILITY_GRID"
TRAJECTORY_BUILDER_2D.submaps.grid_options_2d.resolution = 0.05
TRAJECTORY_BUILDER_2D.submaps.range_data_inserter.probability_grid_range_data_inserter.insert_free_space = true
TRAJECTORY_BUILDER_2D.submaps.range_data_inserter.probability_grid_range_data_inserter.hit_probability = 0.65
TRAJECTORY_BUILDER_2D.submaps.range_data_inserter.probability_grid_range_data_inserter.miss_probability = 0.45

--Global SLAM
POSE_GRAPH.optimize_every_n_nodes = 10

POSE_GRAPH.constraint_builder.max_constraint_distance = 15
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher.linear_search_window = 7
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher.angular_search_window = math.rad(30.)
POSE_GRAPH.constraint_builder.fast_correlative_scan_matcher.branch_and_bound_depth = 10

POSE_GRAPH.constraint_builder.min_score = 0.65
POSE_GRAPH.constraint_builder.ceres_scan_matcher.occupied_space_weight = 20.
POSE_GRAPH.constraint_builder.ceres_scan_matcher.translation_weight = 10.
POSE_GRAPH.constraint_builder.ceres_scan_matcher.rotation_weight = 1.

POSE_GRAPH.matcher_translation_weight = 5e2
POSE_GRAPH.matcher_rotation_weight = 1.6e3

POSE_GRAPH.optimization_problem.acceleration_weight = 1.1e2               -- IMU
POSE_GRAPH.optimization_problem.rotation_weight = 1.6e4
POSE_GRAPH.optimization_problem.local_slam_pose_translation_weight = 1e6  -- scan odom
POSE_GRAPH.optimization_problem.local_slam_pose_rotation_weight = 1e6
POSE_GRAPH.optimization_problem.odometry_translation_weight = 1e4         -- phy odom
POSE_GRAPH.optimization_problem.odometry_rotation_weight = 1e2
POSE_GRAPH.constraint_builder.loop_closure_translation_weight  = 1e7      -- loop
POSE_GRAPH.constraint_builder.loop_closure_rotation_weight = 1e6

POSE_GRAPH.optimization_problem.ceres_solver_options.use_nonmonotonic_steps = true
POSE_GRAPH.optimization_problem.ceres_solver_options.max_num_iterations = 20
POSE_GRAPH.optimization_problem.ceres_solver_options.num_threads = 12

POSE_GRAPH.optimization_problem.huber_scale = 1e-1

POSE_GRAPH.max_num_final_iterations = 500

POSE_GRAPH.constraint_builder.sampling_ratio = 0.3

POSE_GRAPH.log_residual_histograms = true
POSE_GRAPH.constraint_builder.log_matches = true

return options
