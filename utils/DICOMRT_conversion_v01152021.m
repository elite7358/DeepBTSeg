function DICOMRT_conversion_v01152021(origfile, filelist, hashkey, currsoft)
[file,path,indx] = uiputfile('*.dcm');
if ~indx
    return;
end
bar = waitbar(0,'Exporting the DICOM RTSS....');
r = jobmgr.recall(@jobmgr.example.solver, hashkey); %read the cache results
contour = r{1};
if ~isfolder('DeepSeg_files') %make sure files folder exists
    mkdir DeepSeg_files;
end
if currsoft ==1 || currsoft == 3 || currsoft == 4 || currsoft == 5
    fileID = fopen('DeepSeg_files/Seg_results_inverted.nii.gz','w+');
    fwrite(fileID,contour,'*bit8');
    fclose(fileID);
    % gunzip('files\Seg_results_inverted.nii.gz','files\');
    V = niftiread(append(pwd,'/DeepSeg_files/Seg_results_inverted.nii')); %contour
    
elseif currsoft ==2
    fileID = fopen('DeepSeg_files/DeepSeg_results_inverted.nii','w+');
    fwrite(fileID,contour,'*bit8');
    fclose(fileID);
    V = niftiread(append(pwd,'/DeepSeg_files/DeepSeg_results_inverted.nii')); %contour
end

% V = niftiread('DeepSeg_files\Seg_results_inverted.nii.gz');
% V = round(V/1000);
Vtemp1 = niftiread(append('DeepSeg_nii_dir/', origfile,'T1.nii'));
waitbar(0.1);
% trim the padding 200 pixels  
if size(Vtemp1,1)>size(Vtemp1,2)
    pad_to_size = size(Vtemp1,1)+200;
else
    pad_to_size = size(Vtemp1,2)+200;
end
row_start = round((pad_to_size-size(Vtemp1,1))/2);
col_start = round((pad_to_size-size(Vtemp1,2))/2);


V_seg_results_nifti = V(row_start:(row_start+size(Vtemp1,1)-1), col_start:(col_start+size(Vtemp1,2)-1),:);

V_seg_results_ori_T1 = flip(permute(V_seg_results_nifti,[2 1 3]),1); % now it is back to the original T1 orientation
V_seg_results_ori_T1 = flip(V_seg_results_ori_T1, 3);

%%


file_info = filelist;
load('dicomrt_template.mat');

for idx = 1:length(file_info)
    
    %temp1 = double(dicomread(file_info{idx}));
    
    temp2 = dicominfo(file_info{idx});
    mat_pos(:,idx) = temp2.ImagePositionPatient;
    orientation_matrix{idx} = reshape(temp2.ImageOrientationPatient, [3 2]).*[temp2.PixelSpacing temp2.PixelSpacing temp2.PixelSpacing]';
    
    target_img_hdr = temp2;
end
waitbar(0.2);
%%
dicomrt_hdr.StudyInstanceUID = target_img_hdr.StudyInstanceUID;
%dicomrt_hdr.SeriesInstanceUID = target_img_hdr.SeriesInstanceUID;
dicomrt_hdr.PatientName = target_img_hdr.PatientName;
dicomrt_hdr.PatientID = target_img_hdr.PatientID;
dicomrt_hdr.StructureSetLabel = 'Tumor_contour';
dicomrt_hdr.StructureSetName = 'Tumor';
dicomrt_hdr.StructureSetDate = '20200624';
dicomrt_hdr.StructureSetTime = '162300.000000';
dicomrt_hdr.StudyDate = target_img_hdr.StudyDate;
dicomrt_hdr.SeriesDate = target_img_hdr.SeriesDate;

%dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.ReferencedSOPInstanceUID= target_img_hdr.StudyInstanceUID;
dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.FrameOfReferenceUID = target_img_hdr.FrameOfReferenceUID;
dicomrt_hdr.PatientPosition = target_img_hdr.PatientPosition;
dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_1.ContourImageSequence.Item_1.ReferencedSOPClassUID = ...
    target_img_hdr.SOPClassUID;
dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_1.ContourImageSequence.Item_1.ReferencedSOPInstanceUID = ...
    target_img_hdr.SOPInstanceUID;
dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.Item_1.ReferencedSOPClassUID = ...
    target_img_hdr.SOPClassUID;
dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.Item_1.ReferencedSOPInstanceUID = ...
    target_img_hdr.SOPInstanceUID;
dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID = ...
    target_img_hdr.SeriesInstanceUID;
dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.Item_1=rmfield(dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence.Item_1,'ReferencedFrameNumber');
waitbar(0.4);
%%
%dicomrt_hdr.ROIContourSequence = rmfield(dicomrt_hdr.ROIContourSequence,'Item_2');
%dicomrt_hdr.ROIContourSequence = rmfield(dicomrt_hdr.ROIContourSequence,'Item_3');
%dicomrt_hdr.ROIContourSequence = rmfield(dicomrt_hdr.ROIContourSequence,'Item_4');

%dicomrt_hdr.StructureSetROISequence = rmfield(dicomrt_hdr.StructureSetROISequence,'Item_2');
%dicomrt_hdr.StructureSetROISequence = rmfield(dicomrt_hdr.StructureSetROISequence,'Item_3');
%dicomrt_hdr.StructureSetROISequence = rmfield(dicomrt_hdr.StructureSetROISequence,'Item_4');

%dicomrt_hdr.RTROIObservationsSequence = rmfield(dicomrt_hdr.RTROIObservationsSequence,'Item_2');
%dicomrt_hdr.RTROIObservationsSequence = rmfield(dicomrt_hdr.RTROIObservationsSequence,'Item_3');
%dicomrt_hdr.RTROIObservationsSequence = rmfield(dicomrt_hdr.RTROIObservationsSequence,'Item_4');

%%
for idx = 2:9
    dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence = rmfield(dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence,['Item_' num2str(idx)]);
end
for idx = 2:8
    dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence = rmfield(dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence,['Item_' num2str(idx)]);
end
for idx = 2:7
    dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence = rmfield(dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence,['Item_' num2str(idx)]);
end
dicomrt_hdr.ROIContourSequence.Item_5 = dicomrt_hdr.ROIContourSequence.Item_4;
dicomrt_hdr.ROIContourSequence.Item_5.ReferencedROINumber = 5;
dicomrt_hdr.StructureSetROISequence.Item_5 = dicomrt_hdr.StructureSetROISequence.Item_4;
dicomrt_hdr.StructureSetROISequence.Item_5.ROINumber = 5;
for idx = 2:9
    dicomrt_hdr.ROIContourSequence.Item_4.ContourSequence = rmfield(dicomrt_hdr.ROIContourSequence.Item_4.ContourSequence,['Item_' num2str(idx)]);
    dicomrt_hdr.ROIContourSequence.Item_5.ContourSequence = rmfield(dicomrt_hdr.ROIContourSequence.Item_5.ContourSequence,['Item_' num2str(idx)]);
end
for idx = 2:299
    dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence = ...
        rmfield(dicomrt_hdr.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.ContourImageSequence,['Item_' num2str(idx)]);
end
dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_1.ContourImageSequence.Item_1 = ...
    rmfield(dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_1.ContourImageSequence.Item_1,'ReferencedFrameNumber');
dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence.Item_1.ContourImageSequence.Item_1 = ...
    rmfield(dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence.Item_1.ContourImageSequence.Item_1,'ReferencedFrameNumber');
dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_1.ContourImageSequence.Item_1 = ...
    rmfield(dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_1.ContourImageSequence.Item_1,'ReferencedFrameNumber');

dicomrt_hdr.ROIContourSequence.Item_4.ContourSequence.Item_1.ContourImageSequence.Item_1 = ...
    rmfield(dicomrt_hdr.ROIContourSequence.Item_4.ContourSequence.Item_1.ContourImageSequence.Item_1,'ReferencedFrameNumber');
dicomrt_hdr.ROIContourSequence.Item_5.ContourSequence.Item_1.ContourImageSequence.Item_1 = ...
    rmfield(dicomrt_hdr.ROIContourSequence.Item_5.ContourSequence.Item_1.ContourImageSequence.Item_1,'ReferencedFrameNumber');
% dicomrt_hdr.ROIContourSequence.Item_5.ContourSequence.Item_1.ContourImageSequence.Item_1 = ...
%     rmfield(dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_1.ContourImageSequence.Item_1,'ReferencedFrameNumber');

waitbar(0.6);
%%
dicomrt_hdr.ROIContourSequence.Item_1.ROIDisplayColor = [255 0 0]';
dicomrt_hdr.ROIContourSequence.Item_2.ROIDisplayColor = [255 0 255]';
dicomrt_hdr.ROIContourSequence.Item_3.ROIDisplayColor = [255 128 255];
dicomrt_hdr.ROIContourSequence.Item_4.ROIDisplayColor = [255 255 0];
dicomrt_hdr.ROIContourSequence.Item_5.ROIDisplayColor = [0 0 255];

for idx_target = 1:5
    if idx_target==1
        mask1 = flip(((V_seg_results_ori_T1==1) + (V_seg_results_ori_T1==3))>0,3); % img_T1 has been flipped in the 3rd dimension
        now_ROI_name = 'NE+E Tumor';
    elseif idx_target==2
        mask1 = flip((V_seg_results_ori_T1>=1),3); % img_T1 has been flipped in the 3rd dimension
        now_ROI_name = 'Edema+NE+E Tumor';
    elseif idx_target==3
        mask1 = flip(V_seg_results_ori_T1==1,3); % img_T1 has been flipped in the 3rd dimension
        now_ROI_name = 'NE Tumor';
    elseif idx_target==4
        mask1 = flip(V_seg_results_ori_T1==3,3); % img_T1 has been flipped in the 3rd dimension
        now_ROI_name = 'E Tumor';
    else        
        mask1 = flip(V_seg_results_ori_T1==2,3); % img_T1 has been flipped in the 3rd dimension
        now_ROI_name = 'Edema';
    end
    
    slices_to_do = find(sum(mipdim(mask1,1))>0);
    n_slices = length(slices_to_do);
    
    now_item = 0;
    
    for idx1 = 1:n_slices
        now_slice = slices_to_do(idx1);
        tempmask4 = mask1(:,:,now_slice);
        
        label1 = bwlabel(tempmask4);
        label1(find(tempmask4==0)) = -1;
        label_vec = unique(label1(:));
        
        A = zeros(4,4); A(4,4) = 1; A(1:3,4) = mat_pos(:,now_slice);
        A(1:3,1:2) = orientation_matrix{now_slice};
        
        for idx_label = 2:length(label_vec)
            now_item=now_item+1;
            tempmask = label1== label_vec(idx_label);
            [r c] = mask2poly(tempmask);
            pos_vertices = zeros(length(r), 3);
            
            for idx = 1:length(r)
                now_ijk = [c(idx)-1 r(idx)-1 now_slice-1 1]';
                temp1 = A*now_ijk;
                pos_vertices(idx, :) = temp1(1:3)';
            end
            
            tempmat = pos_vertices';
            eval(['dicomrt_hdr.ROIContourSequence.Item_' num2str(idx_target) '.ContourSequence.Item_' num2str(now_item) '.ContourData = tempmat(:);']);
            eval(['dicomrt_hdr.ROIContourSequence.Item_' num2str(idx_target) '.ContourSequence.Item_' num2str(now_item) '.NumberOfContourPoints = length(r);']);
            if now_item >1
                eval(['dicomrt_hdr.ROIContourSequence.Item_' num2str(idx_target) '.ContourSequence.Item_' num2str(now_item) '.ContourGeometricType = dicomrt_hdr.ROIContourSequence.Item_' num2str(idx_target) '.ContourSequence.Item_1.ContourGeometricType;']);
                eval(['dicomrt_hdr.ROIContourSequence.Item_' num2str(idx_target) '.ContourSequence.Item_' num2str(now_item) '.ContourImageSequence = dicomrt_hdr.ROIContourSequence.Item_' num2str(idx_target) '.ContourSequence.Item_1.ContourImageSequence;']);
            end
        end
    end
    eval(['dicomrt_hdr.StructureSetROISequence.Item_' num2str(idx_target) '.ROIName = ''' now_ROI_name ''';']);
end
waitbar(0.8);


% %%
% mask1 = flip(V_seg_results_ori_T1==1,3); % img_T1 has been flipped in the 3rd dimension
% 
% slices_to_do = find(sum(mipdim(mask1,1))>0);
% n_slices = length(slices_to_do);
% 
% now_item = 0;
% 
% for idx1 = 1:n_slices
%     now_slice = slices_to_do(idx1);
%     tempmask4 = mask1(:,:,now_slice);
%         
%     label1 = bwlabel(tempmask4);
%     label1(find(tempmask4==0)) = -1;
%     label_vec = unique(label1(:));
%     
%     A = zeros(4,4); A(4,4) = 1; A(1:3,4) = mat_pos(:,now_slice);
%     A(1:3,1:2) = orientation_matrix{now_slice};
%     
%     for idx_label = 2:length(label_vec)
%         now_item=now_item+1;
%         tempmask = label1== label_vec(idx_label);
%         [r c] = mask2poly(tempmask);
%         pos_vertices = zeros(length(r), 3);
%         
%         for idx = 1:length(r)
%             now_ijk = [c(idx)-1 r(idx)-1 now_slice-1 1]';
%             temp1 = A*now_ijk;
%             pos_vertices(idx, :) = temp1(1:3)';
%         end
%         
%         tempmat = pos_vertices';
%         eval(['dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_' num2str(now_item) '.ContourData = tempmat(:);']);
%         eval(['dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_' num2str(now_item) '.NumberOfContourPoints = length(r);']);
%         if now_item >1
%             eval(['dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_' num2str(now_item) '.ContourGeometricType = dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_1.ContourGeometricType;']);
%             eval(['dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_' num2str(now_item) '.ContourImageSequence = dicomrt_hdr.ROIContourSequence.Item_1.ContourSequence.Item_1.ContourImageSequence;']);
%         end
%     end
% end
% dicomrt_hdr.StructureSetROISequence.Item_1.ROIName = 'AI_NonEnhancingTumor';
% 
% %%
% mask2 = flip(V_seg_results_ori_T1==2,3); % img_T1 has been flipped in the 3rd dimension
% 
% slices_to_do = find(sum(mipdim(mask2,1))>0);
% n_slices = length(slices_to_do);
% now_item = 0;
% 
% for idx1 = 1:n_slices
%     now_slice = slices_to_do(idx1);
%     tempmask4 = mask2(:,:,now_slice);
%     tempmask4 = tempmask4>0.5;
%     
%     
%     label1 = bwlabel(tempmask4);
%     label1(find(tempmask4==0)) = -1;
%     label_vec = unique(label1(:));
%     A = zeros(4,4); A(4,4) = 1; A(1:3,4) = mat_pos(:,now_slice);
%     A(1:3,1:2) = orientation_matrix{now_slice};
%     
%     for idx_label = 2:length(label_vec)
%         now_item=now_item+1;
%         tempmask = label1== label_vec(idx_label);
%         [r c] = mask2poly(tempmask);
%         pos_vertices = zeros(length(r), 3);
%         
%         for idx = 1:length(r)
%             now_ijk = [c(idx)-1 r(idx)-1 now_slice-1 1]';
%             temp1 = A*now_ijk;
%             pos_vertices(idx, :) = temp1(1:3)';
%         end
%         
%         tempmat = pos_vertices';
%         
%         eval(['dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence.Item_' num2str(now_item) '.ContourData = tempmat(:);']);
%         eval(['dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence.Item_' num2str(now_item) '.NumberOfContourPoints = length(r);']);
%         if now_item >1
%             eval(['dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence.Item_' num2str(now_item) '.ContourGeometricType = dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence.Item_1.ContourGeometricType;']);
%             eval(['dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence.Item_' num2str(now_item) '.ContourImageSequence = dicomrt_hdr.ROIContourSequence.Item_2.ContourSequence.Item_1.ContourImageSequence;']);
%         end
%     end
% end
% dicomrt_hdr.StructureSetROISequence.Item_2.ROIName = 'AI_Edema';
% 
% %%
% mask3 = flip(V_seg_results_ori_T1==3,3); % img_T1 has been flipped in the 3rd dimension
% 
% slices_to_do = find(sum(mipdim(mask3,1))>0);
% n_slices = length(slices_to_do);
% now_item = 0;
% 
% for idx1 = 1:n_slices
%     now_slice = slices_to_do(idx1);
%     tempmask4 = mask3(:,:,now_slice);
%     tempmask4 = tempmask4>0.5;
%     
%     
%     label1 = bwlabel(tempmask4);
%     label1(find(tempmask4==0)) = -1;
%     label_vec = unique(label1(:));
%     A = zeros(4,4); A(4,4) = 1; A(1:3,4) = mat_pos(:,now_slice);
%     A(1:3,1:2) = orientation_matrix{now_slice};
%     
%     for idx_label = 2:length(label_vec)
%         now_item=now_item+1;
%         tempmask = label1== label_vec(idx_label);
%         [r c] = mask2poly(tempmask);
%         pos_vertices = zeros(length(r), 3);
%         
%         for idx = 1:length(r)
%             now_ijk = [c(idx)-1 r(idx)-1 now_slice-1 1]';
%             temp1 = A*now_ijk;
%             pos_vertices(idx, :) = temp1(1:3)';
%         end
%         
%         tempmat = pos_vertices';
%         
%         eval(['dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_' num2str(now_item) '.ContourData = tempmat(:);']);
%         eval(['dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_' num2str(now_item) '.NumberOfContourPoints = length(r);']);
%         if now_item >1
%             eval(['dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_' num2str(now_item) '.ContourGeometricType = dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_1.ContourGeometricType;']);
%             eval(['dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_' num2str(now_item) '.ContourImageSequence = dicomrt_hdr.ROIContourSequence.Item_3.ContourSequence.Item_1.ContourImageSequence;']);
%         end
%     end
% end
% dicomrt_hdr.StructureSetROISequence.Item_3.ROIName = 'AI_EnhancingTumor';
% 
%%
% output_filename = fullfile(path, file,'.dcm');
output_filename = fullfile(path, file);
dicomwrite([], output_filename, dicomrt_hdr, 'CreateMode', 'copy')
waitbar(1);
close(bar);



