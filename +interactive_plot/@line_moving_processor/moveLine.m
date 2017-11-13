function moveLine(obj, id)
% TODO: Document this much better
% split this function up into lots of smaller functions!
%
%
cur_line_y_pos = obj.y_positions(id);
cur_mouse_coords = get(obj.fig_handle, 'CurrentPoint');
cur_mouse_y_pos = cur_mouse_coords(2);

line_thickness = obj.THICKNESS;
gap_thickness = line_thickness*2;
%JAH: Not sure if we can have a better name for this ...
top_to_top_thickness = line_thickness + gap_thickness;
half_line_thickness = line_thickness/2;

% checking for moving upward case
if cur_mouse_y_pos > cur_line_y_pos
    % then we are moving upward
    % need to see if the top edge overlaps with the bottom
    % edge...
    
    % determine clump ids
    % ----------------------------------------------------------
    if obj.clump_ids(end) ~= id
        %then the clump is just the currently moving line
        obj.clump_ids = id;
    end
    
    while true
        n_lines_in_clump = length(obj.clump_ids);
        
        
        %T
        %C   -|
        %B    |
        %     |
        %T    |
        %C   -|
        %B
        %
        %
        
        clump_top_edge = cur_mouse_y_pos + top_to_top_thickness*(n_lines_in_clump - 1) + half_line_thickness;
        
        % if the top edge is going to be above the bottom edge of
        % the line above, add that extra line to the clump.
        %- note, the clumps_ids are sorted from top to bottom so that
        %clump_ids(1) is the top most
        next_line_id  = obj.clump_ids(1) - 1;
        
        if next_line_id == 1
            break
        end
        
        next_bottom_edge = obj.y_positions(next_line_id) - half_line_thickness;
        
        if clump_top_edge >= next_bottom_edge
            % -lines at the top have lower ids
            % -to keep clump_ids sorted, add lines at the
            %    beginning for moving upward
            obj.clump_ids = [next_line_id, obj.clump_ids];
        else
            break
        end
    end
    
    %render the lines
    %-----------------------------------------------------------
    n_lines_in_clump = length(obj.clump_ids);
    clump_top_edge = cur_mouse_y_pos + top_to_top_thickness*(n_lines_in_clump - 1) + half_line_thickness;
    boundary = obj.TOP_BOUNDARY;
    
    if clump_top_edge >= boundary
        % calculate line positions downward from boundary
        new_y_positions = boundary - (1:n_lines_in_clump)*(top_to_top_thickness);
    else
        % calculate line positions upward from mouse position
        temp =  cur_mouse_y_pos + (0:(n_lines_in_clump-1))*(top_to_top_thickness);
        new_y_positions = temp(end:-1:1);
    end
elseif cur_mouse_y_pos < cur_line_y_pos
    % then we are moving downward
    % need to see if the bottom edge overlaps with the bottom edge
    
    % determine the clump ids
    if obj.clump_ids(1) ~= id
        %then the clumb is just the currently moving line
        % this case arises if we were previously moving up and then
        % start moving down
        obj.clump_ids = id;
    end
    
    while true
        n_lines_in_clump = length(obj.clump_ids);
        clump_bottom_edge = cur_mouse_y_pos - top_to_top_thickness*(n_lines_in_clump - 1) - half_line_thickness;
        % it the bottom edge is going to be below the top edge of the
        % line below, add that extra line to the clump.
        next_line_id = obj.clump_ids(end) + 1;
        
        if next_line_id == length(obj.line_handles)
            break
        end
        
        next_top_edge = obj.y_positions(next_line_id) + half_line_thickness;
        
        if clump_bottom_edge <= next_top_edge
            %-lines at the bottom have higher ids
            %-to keep the clump_ids sorted, add lines at the end for
            %moving downward
            obj.clump_ids = [obj.clump_ids, next_line_id];
        else
            break
        end
    end
    
    %render the lines
    %---------------------------------
    n_lines_in_clump = length(obj.clump_ids);
    clump_bottom_edge = cur_mouse_y_pos - top_to_top_thickness*(n_lines_in_clump - 1) - half_line_thickness;
    boundary = obj.BOTTOM_BOUNDARY;
    
    if clump_bottom_edge < boundary
        % calculate the line positions upward from the boundary
        new_y_positions = boundary + (n_lines_in_clump:-1:1)*(top_to_top_thickness) - half_line_thickness;
    else
        % calculate the line positions downward from the mouse position
        new_y_positions = cur_mouse_y_pos - (0:(n_lines_in_clump-1))*(top_to_top_thickness);
    end
else % case where the new position and the old position are identical (rare but happens)
    %JAH: Fixed bug, this would collapse all lines to a single point
    return;
    %new_y_positions = cur_mouse_y_pos;
end

% log new y positions and render
%-----------------------------------------------------------
obj.y_positions(obj.clump_ids) = new_y_positions;
% render the new line positions
obj.renderLines();
end