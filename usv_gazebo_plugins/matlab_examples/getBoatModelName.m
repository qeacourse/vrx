function modelname = getBoatModelName(n)
    switch n
        case 1
            modelname = ['shape_1_boat'];
        case 2
            modelname = ['shape_2_boat'];
        case 3
            modelname = ['shape_4_boat'];
         case 4
            modelname = ['shape_8_boat'];
        case 5
            modelname = ['shape_1_boat_medium'];
        case 6
            modelname = ['shape_2_boat_medium'];
        case 7
            modelname = ['shape_4_boat_medium'];
        case 8
            modelname = ['shape_8_boat_medium'];
        case 9
            modelname = ['shape_1_boat_heavy'];
        case 10
            modelname = ['shape_2_boat_heavy'];
        case 11
            modelname = ['shape_4_boat_heavy'];
        case 12
            modelname = ['shape_8_boat_heavy'];
        case 13
            modelname = ['tall_shape_1_boat'];
        case 14
            modelname = ['tall_shape_8_boat'];
        otherwise
            error('Invalid boat');
    end
end