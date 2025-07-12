#!/usr/bin/env python3
"""
Generate points3d_depth.ply file for Replica dataset
"""

import os
import sys
import numpy as np
import json
import glob
from scene.dataset_readers import readReplicaSceneInfo, sample_ply_from_depth, storePly

def generate_pointcloud_for_replica(datapath, output_path=None, sample_nums=100000):
    """
    Generate points3d_depth.ply file for Replica dataset
    
    Args:
        datapath: Path to Replica scene (e.g., ./data/Replica/office0)
        output_path: Output path for points3d_depth.ply (default: datapath/points3d_depth.ply)
        sample_nums: Number of points to sample from depth maps
    """
    if output_path is None:
        output_path = os.path.join(datapath, "points3d_depth.ply")
    
    print(f"Generating point cloud for {datapath}")
    print(f"Output path: {output_path}")
    
    # Read scene info
    scene_info = readReplicaSceneInfo(datapath, eval=False, llffhold=8, frame_start=0, frame_num=50, frame_step=1)
    
    # Get camera info
    cam_infos = scene_info.train_cameras
    
    if len(cam_infos) == 0:
        print("Error: No camera info found!")
        return False
    
    print(f"Found {len(cam_infos)} camera frames")
    
    # Load camera parameters
    with open(os.path.join(datapath, "../cam_params.json"), "r") as f:
        config = json.load(f)["camera"]
    
    # Create intrinsic matrix
    intrinsic = np.eye(3)
    intrinsic[0, 0] = config["fx"]
    intrinsic[1, 1] = config["fx"]  # Note: using fx for both fx and fy as in original code
    intrinsic[0, 2] = config["cx"]
    intrinsic[1, 2] = config["cy"]
    
    # Sample points from depth maps
    print(f"Sampling {sample_nums} points from depth maps...")
    try:
        points, points_color = sample_ply_from_depth(cam_infos, sample_nums, intrinsic)
        
        # Convert colors to 0-255 range
        points_color_255 = (points_color * 255).astype(np.uint8)
        
        # Save as PLY file
        print(f"Saving point cloud to {output_path}")
        storePly(output_path, points, points_color_255)
        
        print(f"Successfully generated {output_path} with {len(points)} points")
        return True
        
    except Exception as e:
        print(f"Error generating point cloud: {e}")
        return False

def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_replica_pointcloud.py <replica_scene_path> [output_path] [sample_nums]")
        print("Example: python generate_replica_pointcloud.py ./data/Replica/office0")
        sys.exit(1)
    
    datapath = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None
    sample_nums = int(sys.argv[3]) if len(sys.argv) > 3 else 100000
    
    if not os.path.exists(datapath):
        print(f"Error: Path {datapath} does not exist!")
        sys.exit(1)
    
    success = generate_pointcloud_for_replica(datapath, output_path, sample_nums)
    
    if success:
        print("Point cloud generation completed successfully!")
    else:
        print("Point cloud generation failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()
