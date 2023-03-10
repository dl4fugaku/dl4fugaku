#define _GNU_SOURCE 1
#include <fcntl.h>
#include <stdio.h>
#include <sched.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <mpi.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <getopt.h>
#include <linux/limits.h>
#include <libgen.h>

void print_usage(char **argv)
{
	printf("Usage: %s <options> src_path dst_path\n", basename(argv[0]));
	printf("Copy a file in parallel using MPI I/O.\n");
	printf("\n");
	printf("Mandatory arguments to long options are mandatory for short options too.\n");
	printf("    -v, --verbose               Print progress information.\n");
	printf("\n");
	printf("Example: \n");
	printf("    %s /lustre/vol01/data.zip /ssd/my_data/\n", basename(argv[0]));
}

double get_time()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);

    return tv.tv_sec + tv.tv_usec * 1e-6;
}

int verbose_flag = 0;
struct option mpicp_options[] = {
	{
		.name =		"verbose",
		.has_arg =	no_argument,
		.flag =		&verbose_flag,
		.val =		'v',
	},
	/* end */
	{ NULL, 0, NULL, 0, },
};

#define BLOCKSIZE (1024UL * 1024 * 1024)

int main(int argc, char *argv[]) {
	int i, opt;
	char *src_path, *__dst_path;
	char dst_path[PATH_MAX];
    int mpi_rank, mpi_size;
    MPI_Info info;
    MPI_File fp;
    MPI_Offset filesize;
    void *buffer = malloc(BLOCKSIZE);
    unsigned long iterations;
	int ret, fd;

	while ((opt = getopt_long(argc, argv, "+v",
					mpicp_options, NULL)) != -1) {
		switch (opt) {

			case 'v':
				verbose_flag = 1;
				break;
	
			default:
				print_usage(argv);
				exit(EXIT_FAILURE);
		}
	}

	if (optind >= argc) {
		print_usage(argv);
		exit(EXIT_FAILURE);
	}

	src_path = argv[optind];
	++optind;
	
	if (optind >= argc) {
		print_usage(argv);
		exit(EXIT_FAILURE);
	}

	if (!basename(src_path)) {
		fprintf(stderr, "error: %s must be a valid file path\n",
			src_path);
		exit(EXIT_FAILURE);
	}

	__dst_path = argv[optind];
	strncpy(dst_path, __dst_path, PATH_MAX);
	if (!strncmp(&dst_path[strlen(dst_path) - 1], "/", 1)) {
		strncpy(&dst_path[strlen(dst_path)],
			basename(src_path), strlen(basename(src_path)));
	}

    MPI_Init(&argc, &argv);

    MPI_Comm_rank(MPI_COMM_WORLD, &mpi_rank);
    MPI_Comm_size(MPI_COMM_WORLD, &mpi_size);

    MPI_Info_create(&info);

    MPI_Info_set(info, "mpiio_coll_contiguous", "true");
    MPI_Info_set(info, "coll_read_bufsize", "134217728");

	ret = MPI_File_open(MPI_COMM_WORLD,
			src_path,
			MPI_MODE_RDONLY,
			info, &fp);
	if (ret && mpi_rank == 0) {
		fprintf(stderr, "error: opening: %s\n", src_path);
		exit(EXIT_FAILURE);
	}

    MPI_File_set_atomicity(fp, 0);
    MPI_File_get_size(fp, &filesize);

	fd = open(dst_path, O_CREAT | O_WRONLY, S_IRUSR | S_IWUSR);
	if (fd < 0) {
		fprintf(stderr, "error: opening: %s\n", dst_path); 	
		exit(EXIT_FAILURE);
	}

	if (verbose_flag && mpi_rank == 0) {
		printf("%s (%lluMB) -> %s ...\n",
			src_path, filesize / (1024 * 1024), dst_path);
	}

    buffer = malloc(BLOCKSIZE);
	if (!buffer) {
		fprintf(stderr, "error: allocating buffer\n");
		exit(EXIT_FAILURE);
	}

	if (verbose_flag && mpi_rank == 0) {
		printf("copying %s (%lluMB) -> %s ...\n",
			src_path, filesize / (1024 * 1024), dst_path);
	}

    iterations = (filesize + (BLOCKSIZE - 1)) / BLOCKSIZE;

    for (i = 0; i < iterations; i++) {
        double end, elapsed;
        double start = get_time();
		size_t to_read = (filesize - i * BLOCKSIZE) > BLOCKSIZE ?
			BLOCKSIZE : (filesize - i * BLOCKSIZE);
		size_t written = 0;
        
		MPI_File_read_all(fp, buffer, to_read, MPI_BYTE, MPI_STATUS_IGNORE);
		while (written < to_read) {
			int ret;
			ret = write(fd, buffer + written, to_read - written);
			if (ret < 0) {
				fprintf(stderr, "error: writing file %s at offset %lu\n",
					dst_path, written);
				exit(EXIT_FAILURE);
			}

			written += ret;
		}

        end = get_time();
        elapsed = end - start;
		
		if (verbose_flag && mpi_rank == 0) {
			printf("%.2f%%: %.2f MB/s\n",
				(float)i * 100 / iterations,
				(float)to_read / elapsed / 1000 / 1000);
		}
    }

    free(buffer);

	close(fd);
    MPI_File_close(&fp);
    MPI_Finalize();

    return 0;
}
