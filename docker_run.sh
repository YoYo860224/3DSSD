docker run -it --rm --gpus all \
    -v /home/yoyo/KITTI/testing:/home/user/3DSSD/dataset/KITTI/object/testing \
    -v /home/yoyo/KITTI/training:/home/user/3DSSD/dataset/KITTI/object/training \
    -v /home/yoyo/KITTI/ImageSets/test.txt:/home/user/3DSSD/dataset/KITTI/object/test.txt \
    -v /home/yoyo/KITTI/ImageSets/train.txt:/home/user/3DSSD/dataset/KITTI/object/train.txt \
    -v /home/yoyo/KITTI/ImageSets/valid.txt:/home/user/3DSSD/dataset/KITTI/object/valid.txt \
    -v /home/yoyo/文件/3DSSD/data:/home/user/3DSSD/data \
    -v /home/yoyo/文件/3DSSD/log:/home/user/3DSSD/log \
    3dssd
