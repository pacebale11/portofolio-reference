      for FILE in $(find */*/overlays/dev -type f -name "kustomization.yaml" | grep -v sri)
      do
        sed -i "s/count: 0/count: 1/g" $FILE
      done