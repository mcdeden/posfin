<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterMapBankInsurance extends Model
{
    protected $table='master_map_banks_insurances';

    public $incrementing = true;

    protected $fillable = [
        'id','bank_id', 'insurance_id'
    ];

    function bank() {
        return $this->belongsTo('App\Models\MasterBank','bank_id','id');
    }

    function insurance() {
        return $this->belongsTo('App\Models\MasterInsurances','insurance_id','id');
    }
}
