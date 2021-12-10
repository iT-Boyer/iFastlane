#!/usr/bin/env python3
# coding=UTF-8

"""
批量编译组件中的静态库
"""

import os, sys, json, shutil

g_result_dir = os.path.expanduser("~/Desktop/targets-result")     # 结果

# 将搜索到文件拷贝到指定文件夹
def cpy_build_files(xcodeproj_dir:str, result_dir:str):
    result_folder = os.path.basename(xcodeproj_dir)
    # 以组件名称为文件夹名
    result_path = os.path.join(result_dir, result_folder)
    if os.path.exists(result_path):
        shutil.rmtree(result_path)
    os.makedirs(result_path)
    # Release-iphoneos
    release_path = os.path.join(xcodeproj_dir, "build/Release-iphoneos")
    if os.path.exists(release_path) == False:
        return
    for file_name in os.listdir(release_path):
        src_path = os.path.join(release_path, file_name)
        dst_path = os.path.join(result_path, file_name)
        if file_name.endswith(".a"):
            shutil.copyfile(src_path, dst_path)
        if file_name.endswith(".bundle"):
            shutil.copytree(src_path, dst_path)
        
# 读取待搜索的名称列表
def read_keywords_list(keywords_path:str):
    if os.path.exists(keywords_path) == False:
        return []
    keywords_list = []
    for line in open(keywords_path):
        line_str = line.strip()
        if line_str == "" or line_str.startswith(r"//"):
            continue
        keywords_list.append(line_str)
    return keywords_list

# 读取 xcodeproj 所在目录
def read_xcodeproj_dir(dst_dir:str, depth=3):
    depth -= 1
    ignore_folder = [".git", ".git-rewrite", "Assets.xcassets", "Pods"]
    for sub_dir in os.listdir(dst_dir):
        if sub_dir.endswith(".xcodeproj"):
            return True, dst_dir
        if depth < 0 or sub_dir in ignore_folder:
            continue
        sub_full_dir = os.path.join(dst_dir, sub_dir)
        if os.path.isdir(sub_full_dir):
            result, result_path = read_xcodeproj_dir(sub_full_dir, depth)
            if result == True:
                return result, result_path
    return False, dst_dir

# 判断路径是否存在
def read_proj_path(dst_path):
    if not os.path.exists(dst_path):
        in_path = input("请拖入或输入组件路径：")
        in_result = read_proj_path(in_path.strip())
        return in_result.strip()
    else:
        return dst_path

# 读取项目 targets
def read_proj_targets(proj_dir:str):
    p_file = os.popen('cd ' + proj_dir + ' && xcodebuild -list -json')
    p_json:str = p_file.read()
    if p_json == "":
        return []
    p_dict = json.loads(p_json)
    return p_dict["project"]["targets"]

# 判断当前列表是否在待编译的列表找那个
def judge_dst_target_or_bundle(target:str, dst_targets:list):
    if target == "" or dst_targets is None:
        return False
    lower_target = target.lower()
    lower_targets = [x.lower() for x in dst_targets]
    # 拼接
    lib_target_a = "lib" + lower_target + ".a"
    target_a = lower_target + ".a"
    target_bundle = lower_target + ".bundle"
    if lower_target in lower_targets or lib_target_a in lower_targets:
        return True
    if target_a in lower_targets or target_bundle in lower_targets:
        return True
    return False

# 编译对应 target
def build_targets(xcodeproj_dir:str, targets:list, dst_targets:list):
    cmd_dir = "cd " + xcodeproj_dir
    for target in targets:
        if judge_dst_target_or_bundle(target, dst_targets) == False:
            continue
        cmd_build = cmd_dir + " && " + "xcodebuild -target " + target + " -configuration Release -arch arm64 -sdk iphoneos"
        print("+" * 30 + "执行命令" + "+" * 30)
        print(cmd_build)
        print("-" * 30 + "执行命令" + "-" * 30)
        os.system(cmd_build)

def clean_alltargets(xcodeproj_dir:str):
    print("*" * 30 + "清理中..." + "*" * 30)
    cmd_dir = "cd " + xcodeproj_dir
    cmd_clean = cmd_dir + " && " + "xcodebuild clean -alltargets"
    os.system(cmd_clean)

# 编译对应组件
def build_proj(proj_dir:str, k_targets:list):
    xcodeproj_result, xcodeproj_dir = read_xcodeproj_dir(proj_dir)
    if xcodeproj_result == False:
        print("Error：找不到xcodeproj文件：" + proj_dir)
        sys.exit()
    print("xcodeproj文件路径：" + xcodeproj_dir)
    targets_list = read_proj_targets(xcodeproj_dir)
    print("Targets列表：" + str(targets_list))
    # 编译前清理
    clean_alltargets(xcodeproj_dir)
    # 编译所有项目
    build_targets(xcodeproj_dir, targets_list, k_targets)
    # 将build文件夹下 .a 和 .bundle 复制
    cpy_build_files(xcodeproj_dir, g_result_dir)
    # 编译copy后清理build文件夹
    clean_alltargets(xcodeproj_dir)

# main
if __name__ == "__main__":
    k_targets_path = os.path.dirname(os.path.abspath(__file__)) + '/keywords-targets.h'
    k_proj_path = os.path.dirname(os.path.abspath(__file__)) + '/keywords-proj.h'
    k_targets_list = read_keywords_list(k_targets_path)
    if len(k_targets_list) == 0:
        print("Error：读取Target列表为空")
        sys.exit()
    # 编译单个工程
    if not os.path.exists(k_proj_path):
        proj_path = read_proj_path('')
        build_proj(proj_path, k_targets_list)
    else:
        # 编译工程列表，读取keywords-proj.h工程列表
        kwords_proj_list = read_keywords_list(k_proj_path)
        for proj_path in kwords_proj_list:
            build_proj(proj_path, k_targets_list)
