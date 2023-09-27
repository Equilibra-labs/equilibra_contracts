
# Pendiente:

1. Armar un suite de test mas amplio, incluyendo invariantes y un unit completo
2. Sumar la idea del token (este tiene que ser un `SuperToken`(_SuperFluid_)) + lo depositado que vaya a _AAVE_ y o a _UNI_(V4)
3. En caso de usar un pool en _UNI_, y que los usuarios tengan cierto peso en la DAO, que la mitad de las fees vayan al sender / al vault de la DAO

# Token:

Features:
----------
- `SuperToken` := Un token compatible con money streams de superfluid
- `AAVE` := Se deposita el colateral en aave y lo generado se usa para financiar la inflacion y para dar un valor (pseudo) estable al token en el tiempo
- `Inflacion_trustless` := Una inflacion controlada permite al equipo de quilibra tener una fuente de financiamiento que escala a medida de que escala el protocolo. Se establece un maximo de inflacion del minimo _APY_ ganado por depositar en aave un token particular. 
    - >[Ejemplo]: si se aceptan _ETH_,_USDC_,_DAI_ y _WBTC_, la inflacion maxima equivale al minimo _APY_ de estos tokens.
    [Propuesta]: Seria conveniete que la inflacion neta oscile entre `(1.1-2.2)%`, asi se puede absorver con las ganancias de forma sencilla
    - >[Mecanismo]: La inflacion se da al momento de mintear el token, el usuario acepta lso terminos (emite evento) y se emite la cantidad que corresponde al usuarii + la inflacion que va al equipo de equilibra
    [Control]: Tiene que existir una forma de asegurar la solvencia, por ejemplo que cada dia/semana (usando automation de chainlink) se actualize el limite de deuda, el cual permita canjear los tokens nuestros por su equivalente en otros tokens o establezca una penalizacion proporcional al objetivo de inflacion.
    
