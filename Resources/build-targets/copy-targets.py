#!/usr/bin/env python3
# coding=UTF-8

"""
批量拷贝文件
"""

import os, shutil

g_scan_dir = os.path.expanduser("~/Desktop/targets-result")     # 扫描结果存放路径
g_dst_dir = os.path.expanduser("~/Desktop/GitJH/JHMainApp")   # 待扫描的文件夹

# 读取文件夹下编译好的文件
def read_all_targets(scan_path:str):
    result_dict = {}
    ignore_folder = [".git", ".git-rewrite", "Assets.xcassets"] # 忽略文件夹加快速度
    for home, dirs, files in os.walk(scan_path):
        base_name:str = os.path.basename(home)
        if base_name in ignore_folder or base_name.endswith(".bundle"):
            dirs[:] = []  # 忽略当前目录下的子目录
            files[:] = [] # 忽略当前目录下的文件
        for tmp_dir in dirs:
            if tmp_dir.endswith(".bundle"):
                bundle_path = os.path.join(home, tmp_dir)
                result_dict[tmp_dir] = bundle_path
        for tmp_file in files:
            if tmp_file.endswith(".a"):
                file_path = os.path.join(home, tmp_file)
                result_dict[tmp_file] = file_path
    return result_dict

'''
拷贝文件到目标路径
dst_path:str    目标文件夹
dst_list:list   目标文件列表
paths_dict:dict 读取的文件列表字典，key-value 结构为 name-path
'''
def cpy_files(dst_path:str, dst_list:list, paths_dict:dict):
    ignore_folder = [".git", ".git-rewrite", "Assets.xcassets"] # 忽略文件夹加快速度
    for home, dirs, files in os.walk(dst_path):
        base_name:str = os.path.basename(home)
        if base_name in ignore_folder or base_name.endswith(".bundle"):
            dirs[:] = []  # 忽略当前目录下的子目录
            files[:] = [] # 忽略当前目录下的文件
        for tmp_dir in dirs:
            if tmp_dir.endswith(".bundle") and tmp_dir in paths_dict.keys() and tmp_dir in dst_list:
                bundle_path = os.path.join(home, tmp_dir)
                shutil.rmtree(bundle_path)
                src_path = paths_dict[tmp_dir]
                shutil.copytree(src_path, bundle_path)
                # 从目标列表中移除
                dst_list.remove(tmp_dir)
        for tmp_file in files:
            if tmp_file.endswith(".a") and tmp_file in paths_dict.keys() and tmp_file in dst_list:
                file_path = os.path.join(home, tmp_file)
                src_path = paths_dict[tmp_file]
                shutil.copyfile(src_path, file_path)
                # 从目标列表中移除
                dst_list.remove(tmp_file)
    print("-" * 60)
    print("未copy的目标为：\n" + str(dst_list))
    print("-" * 60)

# 读取待搜索的名称列表
def read_keywords_list(keywords_path:str):
    if os.path.exists(keywords_path) == False:
        return []
    keywords_list = []
    for line in open(keywords_path):
        line_str = line.strip()
        if line_str == "":
            continue
        if not line_str.endswith(".a"):
            line_str = "lib" + line_str + ".a"
        keywords_list.append(line_str)
    return keywords_list

# 计算差集 z = x.difference(y) 元素包含在 x 中，但不包含在 y 中
def calc_diff(targets_list:list, build_targets:list):
    diff_set = set(targets_list).difference(build_targets)
    print("*" * 60)
    print("未编译的目标为：\n" + str(diff_set))
    print("*" * 60)

if __name__ == "__main__":
    # 读取文件夹下编译好的文件列表，结构name-path
    build_files_dict = read_all_targets(g_scan_dir)
    # 读取想要替换的文件列表
    targets_path = os.path.dirname(os.path.abspath(__file__)) + '/keywords-targets.h'
    targets_list = read_keywords_list(targets_path)
    # 计算编译的列表与目标列表差集
    calc_diff(targets_list, build_files_dict.keys())
    # 将编译的列表copy项目中
    cpy_files(g_dst_dir, targets_list, build_files_dict)
