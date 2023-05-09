#!/bin/bash

allSlurmJobs=$( /usr/local/slurm/bin/squeue -u msaharan -h -t pending,running -r | wc -l )

if [ "$allSlurmJobs" -lt 100 ]
then
  toSubmit=$(( 100 - $allSlurmJobs ))
#  toSubmit=1

  lineReadCounter=0
  newSubmissionCounter=0

  submittedJobs=$(grep -c '.' /vol/augerprime/users/msaharan/simulations/msaharan/icrc23-pre5/electronNeutrino/20230507/submittedJobs.txt)
  cp /vol/augerprime/users/msaharan/simulations/msaharan/icrc23-pre5/electronNeutrino/20230507/submittedJobs.txt /vol/augerprime/users/msaharan/simulations/msaharan/icrc23-pre5/electronNeutrino/20230507/submittedJobsOld.txt
  cp /vol/augerprime/users/msaharan/simulations/msaharan/icrc23-pre5/electronNeutrino/20230507/submittedJobsError.txt /vol/augerprime/users/msaharan/simulations/msaharan/icrc23-pre5/electronNeutrino/20230507/submittedJobsErrorOld.txt
  echo $submittedJobs

  while IFS=" " read -r cpuHours jobFilePath
  do

    echo 'line read counter '"$lineReadCounter"'\n'
    echo 'CPU hours '"$cpuHours"'\n'

    if [ "$lineReadCounter" -lt $(( $submittedJobs )) ]
    then
      echo "Skipped line "
      echo 'line read counter '"$lineReadCounter"'\n'
      lineReadCounter=$(( $lineReadCounter + 1 ))
      continue
    fi

    if [ "$lineReadCounter" -ge $(( $submittedJobs )) ]
    then

      jobId=$(/usr/local/slurm/bin/sbatch --parsable $jobFilePath)

      if [ -z "$jobId" ]
      then
        echo ''"$jobId"' '"$cpuHours"' '"$jobFilePath"''  >> /vol/augerprime/users/msaharan/simulations/msaharan/icrc23-pre5/electronNeutrino/20230507/submittedJobsError.txt
        echo 'Job ID empty '"$jobId"' '"$jobFilePath"'\n'
        break
      fi

      if [ -n "$jobId" ] 
      then
        echo ''"$jobId"' '"$cpuHours"' '"$jobFilePath"''  >> /vol/augerprime/users/msaharan/simulations/msaharan/icrc23-pre5/electronNeutrino/20230507/submittedJobs.txt
        echo 'Submitted job '"$jobId"' '"$jobFilePath"' with '"$cpuHours" h wall time'\n'
        lineReadCounter=$(( $lineReadCounter + 1 ))
        newSubmissionCounter=$(( $newSubmissionCounter + 1 ))

        if [ "$newSubmissionCounter" -ge $(( $toSubmit )) ]
        then
          break
        fi
      fi

    fi

  done < /vol/augerprime/users/msaharan/simulations/msaharan/icrc23-pre5/electronNeutrino/20230507/jobQueueList.txt

fi
