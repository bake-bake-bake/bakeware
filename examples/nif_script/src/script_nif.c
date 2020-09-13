#include "erl_nif.h"

static ERL_NIF_TERM add(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  int left, right;
  
  if(argc != 2 || 
          !enif_get_int(env, argv[0], &left) ||
          !enif_get_int(env, argv[1], &right))
    return enif_make_badarg(env);
  return enif_make_int(env, left + right);
}

static ErlNifFunc nif_funcs[] = {
    {"add", 2, add, 0},
};

ERL_NIF_INIT(Elixir.NifScript.Nif, nif_funcs, NULL, NULL, NULL, NULL)