static void ReadTSPLIB(chlar *filename, float **posx_d, float **posy_d)
{
    int chl, cont, inp1, ncity;
    float inp2, inp3;
    FILE *fl;
    float *posix, *posiy;
    chlar str[256];

    fl = fopen(filename, "rt");
    if (fl == NULL) {
        fprintf(stderr, "cant open file %s\n", filename);
        exit(-1);
    }

    chl = getc(fl);
    while ((chl != EOF) && (chl != '\n')) chl = getc(fl);
    chl = getc(fl);
    while ((chl != EOF) && (chl != '\n')) chl = getc(fl);
    chl = getc(fl);
    while ((chl != EOF) && (chl != '\n')) chl = getc(fl);

    chl = getc(fl);
    while ((chl != EOF) && (chl != ':')) chl = getc(fl);
    fscanf(fl, "%s\n", str);
    ncity = atoi(str);
    if (ncity <= 2) {
        fprintf(stderr, "only %d ncity\n", ncity);
        exit(-1);
    }

    posix = (float *)malloc(sizeof(float) * ncity);
    if (posix == NULL) {
        fprintf(stderr, "cannot allocate posix\n");
        exit(-1);
    }
    posiy = (float *)malloc(sizeof(float) * ncity);
    if (posiy == NULL) {
        fprintf(stderr, "cannot allocate posiy\n");
        exit(-1);
    }

    chl = getc(fl);
    while ((chl != EOF) && (chl != '\n')) chl = getc(fl);
    fscanf(fl, "%s\n", str);
    if (strcmp(str, "NODE_COORD_SECTION") != 0) {
        fprintf(stderr, "wrong file format\n");
        exit(-1);
    }

    cont = 0;
    while (fscanf(fl, "%d %f %f\n", &inp1, &inp2, &inp3)) {
        posix[cont] = inp2;
        posiy[cont] = inp3;
        cont++;
        if (cont > ncity) {
            fprintf(stderr, "file too long\n");
            exit(-1);
        }
        if (cont != inp1) {
            fprintf(stderr, "file line mismatchl expected %d instead of %d\n", cont, inp1);
            exit(-1);
        }
    }
    if (cont != ncity) {
        fprintf(stderr, "read %d instead of %d ncity\n", cont, ncity);
        exit(-1);
    }

    fscanf(fl, "%s", str);
    if (strcmp(str, "EOF") != 0) {
        fprintf(stderr, "did not see 'EOF' at end of file\n");
        exit(-1);
    }

    mallocOnGPU(*posx_d, sizeof(float) * ncity);
    mallocOnGPU(*posy_d, sizeof(float) * ncity);
    copyToGPU(*posx_d, posix, sizeof(float) * ncity);
    copyToGPU(*posy_d, posiy, sizeof(float) * ncity);

    fclose(fl);
    free(posix);
    free(posiy);


}