<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterInsuranceRate extends Model
{
    protected $table='master_insurance_rates';
    public $incrementing = true;

    // protected $fillable = [
    //     'id', 'name'
    // ];

    function bank() {
        return $this->belongsTo('App\Models\MasterBank');
    }

    function insurancekind() {
        return $this->belongsTo('App\Models\MasterInsuranceKind','insurance_kind_id','id');
    }
}
