#!/bin/bash
# trimmed_bionano_errorneous_N 0.0.1


main() {

    echo "Value of input_fastagz: '$input_fastagz'"
    echo "Value of species_id: '$species_id'"

    echo "${input_fastagz_name: -3}"
    if [[ "${input_fastagz_name: -3}" == ".gz" ]]; then    
        dx download "$input_fastagz" -o input.fasta.gz
        gunzip input.fasta.gz
    else
        dx download "$input_fastagz" -o input.fasta
    fi
    trimmed_name="${input_fastagz_name%.gz}"
    trimmed_name="${trimmed_name%.fa}"
    trimmed_name="${trimmed_name%.fasta}"

    python3 remove_fake_cut_sites_DNAnexus.py input.fasta input_trimmedN.fasta output.log
    python3 trim_Ns_DNAnexus.py input_trimmedN.fasta output_list.txt
    python3 clip_regions_DNAnexus.py input_trimmedN.fasta output_list.txt "${trimmed_name}.trimmed.fasta"
    gzip "${trimmed_name}.trimmed.fasta"
    mv "${trimmed_name}.trimmed.fasta.gz" "${species_id}_s2.fasta.gz"


    output_fastagz=$(dx upload "${species_id}_s2.fasta.gz" --brief)
    dx-jobutil-add-output output_fastagz "$output_fastagz" --class=file

    output_list=$(dx upload output_list.txt --brief)
    dx-jobutil-add-output output_list "$output_list" --class=file
}
